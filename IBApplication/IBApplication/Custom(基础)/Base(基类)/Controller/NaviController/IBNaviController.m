//
//  IBNavigationController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/7.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBNaviController.h"
#import "IBModelController.h"

@interface IBNaviController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) UIVisualEffectView *fromFakeBar;
@property (nonatomic, strong) UIVisualEffectView *toFakeBar;
@property (nonatomic, strong) UIImageView *fromFakeShadow;
@property (nonatomic, strong) UIImageView *toFakeShadow;
@property (nonatomic, strong) UIImageView *fromFakeImageView;
@property (nonatomic, strong) UIImageView *toFakeImageView;

@end

@implementation IBNaviController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    return [super initWithRootViewController:rootViewController];
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    return [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController naviBar:(Class)naviBarClass {
    if (self = [super initWithNavigationBarClass:naviBarClass toolbarClass:nil]) {
        self.viewControllers = @[rootViewController];
    }
    return self;
}

BOOL isImageEqual(UIImage *image1, UIImage *image2) {
    if (image1 == image2) {
        return YES;
    }
    if (image1 && image2) {
        NSData *data1 = UIImagePNGRepresentation(image1);
        NSData *data2 = UIImagePNGRepresentation(image2);
        BOOL result = [data1 isEqual:data2];
        return result;
    }
    return NO;
}

BOOL shouldShow(IBModelController *vc,IBModelController *from, IBModelController *to) {
    if (vc != to ) {
        return NO;
    }
    
    if (from.config.backgroundImage && to.config.backgroundImage && isImageEqual(from.config.backgroundImage, to.config.backgroundImage)) {
        // 都有图片，并且是同一张图片
        if (ABS(from.config.alpha - to.config.alpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    if (!from.config.backgroundImage && !to.config.backgroundImage && [from.config.backgroundColor.description isEqual:to.config.backgroundColor.description]) {
        // 都没图片，并且颜色相同
        if (ABS(from.config.alpha - to.config.alpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

- (CGRect)fakeBarFrameForViewController:(UIViewController *)vc {
    UIView *back = self.navigationBar.subviews[0];
    CGRect frame = [self.navigationBar convertRect:back.frame toView:vc.view];
    frame.origin.x = vc.view.frame.origin.x;
    //  解决根视图为scrollView的时候，Push不正常
    if ([vc.view isKindOfClass:[UIScrollView class]]) {
        //  适配iPhoneX
        frame.origin.y = -([UIScreen mainScreen].bounds.size.height == 812.0 ? 88 : 64);
    }
    return frame;
}

- (CGRect)fakeShadowFrameWithBarFrame:(CGRect)frame {
    return CGRectMake(frame.origin.x, frame.size.height + frame.origin.y - 0.5, frame.size.width, 0.5);
}

- (void)clearFake {
    [_fromFakeBar removeFromSuperview];
    [_toFakeBar removeFromSuperview];
    [_fromFakeShadow removeFromSuperview];
    [_toFakeShadow removeFromSuperview];
    [_fromFakeImageView removeFromSuperview];
    [_toFakeImageView removeFromSuperview];
    _fromFakeBar = nil;
    _toFakeBar = nil;
    _fromFakeShadow = nil;
    _toFakeShadow = nil;
    _fromFakeImageView = nil;
    _toFakeImageView = nil;
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"123");
    
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    viewController = (IBModelController *)viewController;
    if (coordinator) {
        IBModelController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
        IBModelController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (shouldShow(viewController, from, to)) {

                [self updateNavigationBarAnimatedForController:viewController];

                [UIView performWithoutAnimation:^{
                    self.naviBar.effectView.alpha = 0;
                    self.naviBar.shadowImgView.alpha = 0;
                    self.naviBar.backgroundImgView.alpha = 0;
                    
                    // from
                    self.fromFakeImageView.image = from.config.backgroundImage;
                    self.fromFakeImageView.alpha = from.config.alpha;
                    self.fromFakeImageView.frame = [self fakeBarFrameForViewController:from];
                    [from.view addSubview:self.fromFakeImageView];
                    
                    self.fromFakeBar.subviews.lastObject.backgroundColor = from.config.backgroundColor;
                    self.fromFakeBar.alpha = from.config.alpha == 0 || from.config.backgroundImage ? 0.01:from.config.alpha;
                    if (from.config.alpha == 0 || from.config.backgroundImage) {
                        self.fromFakeBar.subviews.lastObject.alpha = 0.01;
                    }
                    self.fromFakeBar.frame = [self fakeBarFrameForViewController:from];
                    [from.view addSubview:self.fromFakeBar];
                    
                    self.fromFakeShadow.alpha = from.config.alpha;
                    self.fromFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.fromFakeBar.frame];
                    [from.view addSubview:self.fromFakeShadow];
                    
                    // to
                    self.toFakeImageView.image = to.config.backgroundImage;
                    self.toFakeImageView.alpha = to.config.alpha;
                    self.toFakeImageView.frame = [self fakeBarFrameForViewController:to];
                    [to.view addSubview:self.toFakeImageView];
                    
                    self.toFakeBar.subviews.lastObject.backgroundColor = to.config.backgroundColor;
                    self.toFakeBar.alpha = to.config.backgroundImage ? 0 : to.config.alpha;
                    self.toFakeBar.frame = [self fakeBarFrameForViewController:to];
                    [to.view addSubview:self.toFakeBar];
                    
                    self.toFakeShadow.alpha = to.config.alpha;
                    self.toFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.toFakeBar.frame];
                    [to.view addSubview:self.toFakeShadow];
                }];
            } else {
                [self updateNavigationBarForViewController:viewController];
            }
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (context.isCancelled) {
                [self updateNavigationBarForViewController:from];
            } else {
                // 当 present 时 to 不等于 viewController
                [self updateNavigationBarForViewController:viewController];
            }
            if (to == viewController) {
                [self clearFake];
            }
        }];
        
        if (@available(iOS 10.0, *)) {
            [coordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                if (!context.isCancelled) {
                    [self updateNavigationBarAnimatedForController:viewController];
                }
            }];
        } else {
            [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                if (!context.isCancelled) {
                    [self updateNavigationBarAnimatedForController:viewController];
                }
            }];
        }
    } else {
        [self updateNavigationBarForViewController:viewController];
    }
}

- (UIVisualEffectView *)fromFakeBar {
    if (!_fromFakeBar) {
        _fromFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _fromFakeBar;
}

- (UIVisualEffectView *)toFakeBar {
    if (!_toFakeBar) {
        _toFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _toFakeBar;
}

- (UIImageView *)fromFakeImageView {
    if (!_fromFakeImageView) {
        _fromFakeImageView = [[UIImageView alloc] init];
    }
    return _fromFakeImageView;
}

- (UIImageView *)toFakeImageView {
    if (!_toFakeImageView) {
        _toFakeImageView = [[UIImageView alloc] init];
    }
    return _toFakeImageView;
}

- (UIImageView *)fromFakeShadow {
    if (!_fromFakeShadow) {
        _fromFakeShadow = [[UIImageView alloc] initWithImage:self.naviBar.shadowImgView.image];
        _fromFakeShadow.backgroundColor = self.naviBar.shadowImgView.backgroundColor;
    }
    return _fromFakeShadow;
}

- (UIImageView *)toFakeShadow {
    if (!_toFakeShadow) {
        _toFakeShadow = [[UIImageView alloc] initWithImage:self.naviBar.shadowImgView.image];
        _toFakeShadow.backgroundColor = self.naviBar.shadowImgView.backgroundColor;
    }
    return _toFakeShadow;
}

- (void)updateNavigationBarForViewController:(IBModelController *)vc {
    [self updateNavigationBarAlphaForViewController:vc];
    [self updateNavigationBarColorOrImageForViewController:vc];
    [self updateNavigationBarShadowIAlphaForViewController:vc];
    [self updateNavigationBarAnimatedForController:vc];
}

- (void)updateNavigationBarAnimatedForController:(IBModelController *)vc {
    self.naviBar.barStyle = vc.config.barStyle;
    self.naviBar.tintColor = vc.config.tintColor;
}

- (void)updateNavigationBarAlphaForViewController:(IBModelController *)vc {
    
    if (vc.config.backgroundImage) {
        self.naviBar.effectView.alpha = 0;
        self.naviBar.backgroundImgView.alpha = vc.config.alpha;
    } else {
        self.naviBar.effectView.alpha = vc.config.alpha;
        self.naviBar.backgroundImgView.alpha = 0;
    }
    self.naviBar.shadowImgView.alpha = vc.config.alpha;
}

- (void)updateNavigationBarColorOrImageForViewController:(IBModelController *)vc {
    self.naviBar.barTintColor = vc.config.backgroundColor;
    self.naviBar.backgroundImgView.image = vc.config.backgroundImage;
}

- (void)updateNavigationBarShadowIAlphaForViewController:(IBModelController *)vc {
    self.naviBar.shadowImgView.alpha = vc.config.alpha;
}

#pragma mark - 合成存取

/**
 当同时实现settter，getter方法时，需要实现成员变量
 因为@synthesize不起作用了
 */
- (IBNaviBar *)naviBar {
    if (self.navigationBar && [self.navigationBar isKindOfClass:[IBNaviBar class]]) {
        return (IBNaviBar *)self.navigationBar;
    }
    return nil;
}

#pragma mark - 控制状态栏

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.visibleViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.visibleViewController;
}

#pragma mark - 控制屏幕旋转

- (BOOL)shouldAutorotate {
    return self.visibleViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.visibleViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.visibleViewController.preferredInterfaceOrientationForPresentation;
}

@end
