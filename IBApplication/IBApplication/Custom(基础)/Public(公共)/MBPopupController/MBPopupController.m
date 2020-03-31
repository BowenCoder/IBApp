//
//  MBPopupController.m
//  IBApplication
//
//  Created by Bowen on 2020/3/31.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBPopupController.h"
#import "MBKeyboardManager.h"
#import "UIViewController+Ext.h"
#import "UIMacros.h"

/// 专用于MBPopupController的UIWindow，这样才能在`UIApplication.sharedApplication.windows`里方便地区分出来
@interface MBPopupControllerWindow : UIWindow

@end

@implementation MBPopupControllerWindow

- (void)layoutSubviews {
    [super layoutSubviews];
    // 避免来电状态时只 popup 的遮罩只盖住一部分的状态栏
    // 但在 iOS 13 及以后，来电状态下状态栏的高度不会再变化了
    if (@available(iOS 13.0, *)) {
    } else {
        if (self.rootViewController) {
            UIView *rootView = self.rootViewController.view;
            if (CGRectGetMinY(rootView.frame) > 0 && !UIApplication.sharedApplication.statusBarHidden && kStatusBarHeight > CGRectGetMinY(rootView.frame)) {
                rootView.frame = self.bounds;
            }
        }
    }

}

@end


@interface MBPopupController ()<MBKeyboardManagerDelegate>

@property (nonatomic, strong) MBPopupControllerWindow *containerWindow;
@property (nonatomic, weak) UIWindow *previousKeyWindow;

@property (nonatomic, assign, readwrite, getter=isVisible) BOOL visible;

@property (nonatomic, assign) BOOL appearAnimated;
@property (nonatomic, copy) void (^appearCompletionBlock)(BOOL finished);

@property (nonatomic, assign) BOOL disappearAnimated;
@property (nonatomic, copy) void (^disappearCompletionBlock)(BOOL finished);

/// 标志 popup 本身以 present 的形式显示之后，又再继续 present 了一个子界面后从子界面回来时触发的 viewWillAppear:
@property (nonatomic, assign) BOOL viewWillAppearByPresentedViewController;

/// 标志是否已经走过一次viewWillDisappear了，用于hideInView的情况
@property (nonatomic, assign) BOOL hasAlreadyViewWillDisappear;

/// 如果用 showInView 的方式显示浮层，则在浮层所在的父界面被 pop（或 push 到下一个界面）时，会自动触发 viewWillDisappear:，导致浮层被隐藏，为了保证走到 viewWillDisappear: 一定是手动调用 hide 的，就加了这个标志位
@property (nonatomic, assign) BOOL willHideInView;

@property (nonatomic, strong) UITapGestureRecognizer *dimmingViewTapGestureRecognizer;
@property (nonatomic, strong) MBKeyboardManager *keyboardManager;
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation MBPopupController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    
    self.animationStyle = MBPopupControllerAnimationFade;
    self.contentViewMargins = UIEdgeInsetsMake(20, 20, 20, 20);
    self.maximumContentViewWidth = CGFLOAT_MAX;
    self.onlyRespondsToKeyboardEventFromDescendantViews = YES;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.modalPresentationStyle = UIModalPresentationCustom;
    
    self.supportedOrientationMask = UIInterfaceOrientationMaskAll;
    
    self.keyboardManager = [[MBKeyboardManager alloc] initWithDelegate:self];
    [self initDefaultDimmingViewWithoutAddToView];

}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.contentViewController) {
        // 在 IB 里设置了 contentViewController 的话，通过这个调用去触发 contentView 的更新
        self.contentViewController = self.contentViewController;
    }
}

- (void)dealloc {
    self.containerWindow = nil;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    // 屏蔽对childViewController的生命周期函数的自动调用，改为手动控制
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.dimmingView && !self.dimmingView.superview) {
        [self.view addSubview:self.dimmingView];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.dimmingView.frame = self.view.bounds;
    
    CGRect contentViewFrame = [self contentViewFrameForShowing];
    if (self.layoutBlock) {
        self.layoutBlock(self.view.bounds, self.keyboardHeight, contentViewFrame);
    } else {
        self.contentView.frame = contentViewFrame;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.shownInWindowMode) {
        // 只有使用showWithAnimated:completion:显示出来的浮层，才需要修改之前就记住的animated的值
        animated = self.appearAnimated;
    }
    
    self.keyboardManager.delegateEnabled = YES;
    
    if (self.contentViewController) {
        [self.contentViewController beginAppearanceTransition:YES animated:animated];
    }
    
    // 如果是因为 present 了新的界面再从那边回来，导致走到 viewWillAppear，则后面那些升起浮层的操作都可以不用做了，因为浮层从来没被降下去过
    self.viewWillAppearByPresentedViewController = [self isShowingPresentedViewController];
    if (self.viewWillAppearByPresentedViewController) {
        return;
    }
    
    if (self.isShownInWindowMode) {
        UIWindow *window = UIApplication.sharedApplication.delegate.window;
        window.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        [window tintColorDidChange];
    }
    
    void (^didShownCompletion)(BOOL finished) = ^(BOOL finished) {
        if (self.contentViewController) {
            [self.contentViewController endAppearanceTransition];
        }
        
        self.visible = YES;
        
        if (self.appearCompletionBlock) {
            self.appearCompletionBlock(finished);
            self.appearCompletionBlock = nil;
        }
        
        self.appearAnimated = NO;
    };
    
    if (animated) {
        [self.view addSubview:self.contentView];
        [self.view layoutIfNeeded];
        
        CGRect contentViewFrame = [self contentViewFrameForShowing];
        if (self.showingAnimation) {
            // 使用自定义的动画
            if (self.layoutBlock) {
                self.layoutBlock(self.view.bounds, self.keyboardHeight, contentViewFrame);
                contentViewFrame = self.contentView.frame;
            }
            self.showingAnimation(self.dimmingView, self.view.bounds, self.keyboardHeight, contentViewFrame, didShownCompletion);
        } else {
            self.contentView.frame = contentViewFrame;
            [self.contentView setNeedsLayout];
            [self.contentView layoutIfNeeded];
            
            [self showingAnimationWithCompletion:didShownCompletion];
        }
    } else {
        CGRect contentViewFrame = [self contentViewFrameForShowing];
        self.contentView.frame = contentViewFrame;
        [self.view addSubview:self.contentView];
        self.dimmingView.alpha = 1;
        didShownCompletion(YES);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.viewWillAppearByPresentedViewController) {
        if (self.contentViewController) {
            [self.contentViewController endAppearanceTransition];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.hasAlreadyViewWillDisappear) {
        return;
    }
    
    /// 如果用 showInView 的方式显示浮层，则在浮层所在的父界面被 pop（或 push 到下一个界面）时，会自动触发 viewWillDisappear:，导致浮层被隐藏，为了保证走到 viewWillDisappear: 一定是手动调用 hide 的，就用 willHideInView 来区分。
    if (self.shownInSubviewMode && !self.willHideInView) {
        return;
    }
    
    [super viewWillDisappear:animated];
    
    if (self.shownInWindowMode) {
        animated = self.disappearAnimated;
    }
    
    BOOL willDisappearByPresentedViewController = [self isShowingPresentedViewController];
    
    if (!willDisappearByPresentedViewController) {
        if ([self.delegate respondsToSelector:@selector(willHidePopupController:)]) {
            [self.delegate willHidePopupController:self];
        }
    }
    
    // 在降下键盘前取消对键盘事件的监听，从而避免键盘影响隐藏浮层的动画
    self.keyboardManager.delegateEnabled = NO;
    [self.view endEditing:YES];
    
    if (self.contentViewController) {
        [self.contentViewController beginAppearanceTransition:NO animated:animated];
    }
    
    // 如果是因为 present 了新的界面导致走到 willDisappear，则后面那些降下浮层的操作都可以不用做了
    if (willDisappearByPresentedViewController) {
        return;
    }
    
    if (self.isShownInWindowMode) {
        UIWindow *window = UIApplication.sharedApplication.delegate.window;
        window.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
        [window tintColorDidChange];
    }
    
    void (^didHiddenCompletion)(BOOL finished) = ^(BOOL finished) {
        
        if (self.shownInWindowMode) {
            // 恢复 keyWindow 之前做一下检查，避免键盘升起来后会立即降下
            if (UIApplication.sharedApplication.keyWindow == self.containerWindow) {
                if (self.previousKeyWindow.hidden) {
                    // 避免主 window 丢失 keyWindow
                    [UIApplication.sharedApplication.delegate.window makeKeyWindow];
                } else {
                    [self.previousKeyWindow makeKeyWindow];
                }
            }
            self.containerWindow.hidden = YES;
            self.containerWindow.rootViewController = nil;
            self.previousKeyWindow = nil;
            [self endAppearanceTransition];
        }
        
        if (self.shownInSubviewMode) {
            self.willHideInView = NO;
            
            // 这句是给addSubview的形式显示的情况下使用，但会触发第二次viewWillDisappear:，所以要搭配self.hasAlreadyViewWillDisappear使用
            [self.view removeFromSuperview];
            self.hasAlreadyViewWillDisappear = NO;
        }
        
        [self.contentView removeFromSuperview];
        if (self.contentViewController) {
            [self.contentViewController endAppearanceTransition];
        }
        
        self.visible = NO;
        
        if ([self.delegate respondsToSelector:@selector(didHidePopupController:)]) {
            [self.delegate didHidePopupController:self];
        }
        
        if (self.disappearCompletionBlock) {
            self.disappearCompletionBlock(YES);
            self.disappearCompletionBlock = nil;
        }
        
        if (self.contentViewController) {
            self.contentViewController = nil;
        }
        
        self.disappearAnimated = NO;
    };
    
    if (animated) {
        if (self.hidingAnimation) {
            self.hidingAnimation(self.dimmingView, self.view.bounds, self.keyboardHeight, didHiddenCompletion);
        } else {
            [self hidingAnimationWithCompletion:didHiddenCompletion];
        }
    } else {
        didHiddenCompletion(YES);
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    BOOL willDisappearByPresentedViewController = [self isShowingPresentedViewController];
    if (willDisappearByPresentedViewController) {
        if (self.contentViewController) {
            [self.contentViewController endAppearanceTransition];
        }
    }
}

- (void)updateLayout {
    if ([self isViewLoaded]) {
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }
}

#pragma mark - Dimming View

- (void)setDimmingView:(UIView *)dimmingView {
    if (![self isViewLoaded]) {
        _dimmingView = dimmingView;
    } else {
        [self.view insertSubview:dimmingView belowSubview:_dimmingView];
        [_dimmingView removeFromSuperview];
        _dimmingView = dimmingView;
        [self.view setNeedsLayout];
    }
    [self addTapGestureRecognizerToDimmingViewIfNeeded];
}

- (void)initDefaultDimmingViewWithoutAddToView {
    if (!self.dimmingView) {
        _dimmingView = [[UIView alloc] init];
        self.dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
        [self addTapGestureRecognizerToDimmingViewIfNeeded];
        if ([self isViewLoaded]) {
            [self.view addSubview:self.dimmingView];
        }
    }
}

// 要考虑用户可能创建了自己的dimmingView，则tap手势也要重新添加上去
- (void)addTapGestureRecognizerToDimmingViewIfNeeded {
    if (!self.dimmingView) {
        return;
    }
    
    if (self.dimmingViewTapGestureRecognizer.view == self.dimmingView) {
        return;
    }
    
    if (!self.dimmingViewTapGestureRecognizer) {
        self.dimmingViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDimmingViewTapGestureRecognizer:)];
    }
    [self.dimmingView addGestureRecognizer:self.dimmingViewTapGestureRecognizer];
    self.dimmingView.userInteractionEnabled = YES;
}

- (void)handleDimmingViewTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.modal) {
        return;
    }
    
    if (self.shownInWindowMode) {
        __weak __typeof(self)weakSelf = self;
        [self hideWithAnimated:YES completion:^(BOOL finished) {
            if (weakSelf.didHideByDimmingViewTappedBlock) {
                weakSelf.didHideByDimmingViewTappedBlock();
            }
        }];
    } else if (self.shownInPresentedMode) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.didHideByDimmingViewTappedBlock) {
                self.didHideByDimmingViewTappedBlock();
            }
        }];
    } else if (self.shownInSubviewMode) {
        __weak __typeof(self)weakSelf = self;
        [self hideInView:self.view.superview animated:YES completion:^(BOOL finished) {
            if (weakSelf.didHideByDimmingViewTappedBlock) {
                weakSelf.didHideByDimmingViewTappedBlock();
            }
        }];
    }
}

#pragma mark - ContentView

- (void)setContentViewController:(UIViewController<MBPopupControllerProtocol> *)contentViewController {
    _contentViewController = contentViewController;
    self.contentView = contentViewController.view;
}

#pragma mark - Showing and Hiding

- (void)showingAnimationWithCompletion:(void (^)(BOOL))completion {
    if (self.animationStyle == MBPopupControllerAnimationFade) {
        self.dimmingView.alpha = 0.0;
        self.contentView.alpha = 0.0;
        [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
        
    } else if (self.animationStyle == MBPopupControllerAnimationPopup) {
        self.dimmingView.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            self.contentView.transform = CGAffineTransformIdentity;
            if (completion) {
                completion(finished);
            }
        }];
        
    } else if (self.animationStyle == MBPopupControllerAnimationSlide) {
        self.dimmingView.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.contentView.frame));
        [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    }
}

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    // makeKeyAndVisible 导致的 viewWillAppear: 必定 animated 是 NO 的，所以这里用额外的变量保存这个 animated 的值
    self.appearAnimated = animated;
    self.appearCompletionBlock = completion;
    self.previousKeyWindow = UIApplication.sharedApplication.keyWindow;
    if (!self.containerWindow) {
        self.containerWindow = [[MBPopupControllerWindow alloc] init];
        self.containerWindow.windowLevel = UIWindowLevelAlert;
        self.containerWindow.backgroundColor = [UIColor clearColor];// 避免横竖屏旋转时出现黑色
    }
    self.containerWindow.rootViewController = self;
    [self.containerWindow makeKeyAndVisible];
}

- (void)hidingAnimationWithCompletion:(void (^)(BOOL))completion {
    if (self.animationStyle == MBPopupControllerAnimationFade) {
        [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    } else if (self.animationStyle == MBPopupControllerAnimationPopup) {
        [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        } completion:^(BOOL finished) {
            if (completion) {
                self.contentView.transform = CGAffineTransformIdentity;
                completion(finished);
            }
        }];
    } else if (self.animationStyle == MBPopupControllerAnimationSlide) {
        [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.contentView.frame));
        } completion:^(BOOL finished) {
            if (completion) {
                self.contentView.transform = CGAffineTransformIdentity;
                completion(finished);
            }
        }];
    }
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    self.disappearAnimated = animated;
    self.disappearCompletionBlock = completion;
    
    BOOL shouldHide = YES;
    if ([self.delegate respondsToSelector:@selector(shouldHidePopupController:)]) {
        shouldHide = [self.delegate shouldHidePopupController:self];
    }
    if (!shouldHide) {
        return;
    }
    
    // window模式下，通过手动触发viewWillDisappear:来做界面消失的逻辑
    if (self.shownInWindowMode) {
        [self beginAppearanceTransition:NO animated:animated];
    }
}

- (void)showInView:(UIView *)view animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    self.appearCompletionBlock = completion;
    [self loadViewIfNeeded];
    [self beginAppearanceTransition:YES animated:animated];
    [view addSubview:self.view];
    [self endAppearanceTransition];
}

- (void)hideInView:(UIView *)view animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    self.willHideInView = YES;
    self.disappearCompletionBlock = completion;
    [self beginAppearanceTransition:NO animated:animated];
    self.hasAlreadyViewWillDisappear = YES;
    [self endAppearanceTransition];
}

- (CGRect)contentViewFrameForShowing {
    CGSize contentViewContainerSize = CGSizeMake(CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentViewMargins), CGRectGetHeight(self.view.bounds) - self.keyboardHeight - UIEdgeInsetsGetVerticalValue(self.contentViewMargins));
    CGSize contentViewLimitSize = CGSizeMake(fmin(self.maximumContentViewWidth, contentViewContainerSize.width), contentViewContainerSize.height);
    CGSize contentViewSize = CGSizeZero;
    if ([self.contentViewController respondsToSelector:@selector(preferredContentSizeInPopupController:keyboardHeight:limitSize:)]) {
        contentViewSize = [self.contentViewController preferredContentSizeInPopupController:self keyboardHeight:self.keyboardHeight limitSize:contentViewLimitSize];
    } else {
        contentViewSize = [self.contentView sizeThatFits:contentViewLimitSize];
    }
    contentViewSize.width = fmin(contentViewLimitSize.width, contentViewSize.width);
    contentViewSize.height = fmin(contentViewLimitSize.height, contentViewSize.height);
    CGRect contentViewFrame = CGRectMake(CGFloatGetCenter(contentViewContainerSize.width, contentViewSize.width) + self.contentViewMargins.left, CGFloatGetCenter(contentViewContainerSize.height, contentViewSize.height) + self.contentViewMargins.top, contentViewSize.width, contentViewSize.height);
    return contentViewFrame;
}

- (BOOL)isShownInWindowMode {
    return !!self.containerWindow;
}

- (BOOL)isShownInPresentedMode {
    return !self.shownInWindowMode && self.presentingViewController && self.presentingViewController.presentedViewController == self;
}

- (BOOL)isShownInSubviewMode {
    return !self.shownInWindowMode && !self.shownInPresentedMode && self.view.superview;
}

- (BOOL)isShowingPresentedViewController {
    return self.shownInPresentedMode && self.presentedViewController && self.presentedViewController.presentingViewController == self;
}

#pragma mark - <MBKeyboardManagerDelegate>

- (void)keyboardWillChangeFrameWithKeyboardInfo:(MBKeyboardInfo *)keyboardInfo
{
    if (self.onlyRespondsToKeyboardEventFromDescendantViews) {
        UIResponder *firstResponder = keyboardInfo.targetResponder;
        if (!firstResponder || !([firstResponder isKindOfClass:[UIView class]] && [(UIView *)firstResponder isDescendantOfView:self.view])) {
            return;
        }
    }
    self.keyboardHeight = [keyboardInfo heightInView:self.view];
    [self updateLayout];
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
    UIViewController *visibleViewController = [UIViewController mb_currentViewController];
    if (visibleViewController != self && [visibleViewController respondsToSelector:@selector(shouldAutorotate)]) {
        return [visibleViewController shouldAutorotate];
    }
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *visibleViewController = [UIViewController mb_currentViewController];
    if (visibleViewController != self && [visibleViewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [visibleViewController supportedInterfaceOrientations];
    }
    return self.supportedOrientationMask;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    if (self.shownInPresentedMode) {
        return self.contentViewController;
    }
    return [super childViewControllerForStatusBarStyle];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    if (self.shownInPresentedMode) {
        return self.contentViewController;
    }
    return [super childViewControllerForStatusBarHidden];
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    if (self.shownInPresentedMode) {
        return self.contentViewController;
    }
    return [super childViewControllerForHomeIndicatorAutoHidden];
}

@end

@implementation MBPopupController (Manager)

+ (BOOL)isAnyPopupControllerVisible {
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        if ([window isKindOfClass:[MBPopupControllerWindow class]] && !window.hidden) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)hideAllVisiblePopupControllerIfCan {
    
    BOOL hideAllFinally = YES;
    
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        if (![window isKindOfClass:[MBPopupControllerWindow class]]) {
            continue;
        }
        
        // 存在popupViewController，但并没有显示出来，所以不用处理
        if (window.hidden) {
            continue;
        }
        
        // 存在window，但不存在popupViewController，则直接把这个window移除
        if (!window.rootViewController) {
            window.hidden = YES;
            continue;
        }
        
        MBPopupController *popupController = (MBPopupController *)window.rootViewController;
        BOOL canHide = YES;
        if ([popupController.delegate respondsToSelector:@selector(shouldHidePopupController:)]) {
            canHide = [popupController.delegate shouldHidePopupController:popupController];
        }
        if (canHide) {
            // 如果某些控件的显隐能力是通过 MBPopupController 实现的，那么隐藏它们时，应该用它们自己的 hide 方法，而不是 MBPopupController 自带的 hideWithAnimated:completion:
            id<MBPopupControllerComponentProtocol> popupComponent = nil;
            if ([popupController.contentViewController conformsToProtocol:@protocol(MBPopupControllerComponentProtocol)]) {
                popupComponent = (id<MBPopupControllerComponentProtocol>)popupController.contentViewController;
            } else if ([popupController.contentView conformsToProtocol:@protocol(MBPopupControllerComponentProtocol)]) {
                popupComponent = (id<MBPopupControllerComponentProtocol>)popupController.contentView;
            }
            if (popupComponent) {
                [popupComponent hidePopupControllerComponent];
            } else {
                [popupController hideWithAnimated:NO completion:nil];
            }
        } else {
            // 只要有一个popController正在显示但却无法被隐藏，就返回NO
            hideAllFinally = NO;
        }
    }
    
    return hideAllFinally;
}

@end
