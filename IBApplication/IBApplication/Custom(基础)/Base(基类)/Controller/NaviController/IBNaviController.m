//
//  IBNavigationController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/7.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBNaviController.h"

@interface IBNaviController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIToolbar *fromNaviBar;
@property (nonatomic, strong) UIToolbar *toNaviBar;
@property (nonatomic, strong) IBNaviConfig *defaultConfig;

@end

@implementation IBNaviController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController naviBar:(Class)naviBarClass {
    if (self = [super initWithNavigationBarClass:naviBarClass toolbarClass:nil]) {
        self.viewControllers = @[rootViewController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (coordinator) {
        UIViewController *fromVC = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toVC = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        IBNaviConfig *fromConfig = fromVC.config ? fromVC.config : self.defaultConfig;
        IBNaviConfig *toConfig = toVC.config ? toVC.config : self.defaultConfig;
        
        if (toConfig.hidden != navigationController.navigationBarHidden) {
            [navigationController setNavigationBarHidden:toConfig.hidden animated:animated];
        }
        
        BOOL showBar = shouldShow(fromConfig, toConfig);
        IBNaviConfig *transparentConfig = nil;
        if (showBar) {
            IBNaviBarOption transparentOption = IBNaviBarOptionDefault | IBNaviBarOptionTransparent;
            if (toConfig.barStyle == UIBarStyleBlack) transparentOption |= IBNaviBarOptionBlack;
            transparentConfig = [[IBNaviConfig alloc] initWithBarOptions:transparentOption tintColor:nil backgroundColor:nil backgroundImage:nil backgroundImgID:nil];
        }
        
        if (!toConfig.hidden) {
            [self.naviBar updateNaviBarConfig:transparentConfig ? transparentConfig : toConfig];
        } else {
            [self.naviBar updateBarStyle:toConfig.barStyle tintColor:toConfig.tintColor];
        }
        
        if (!animated) {
            return;
        }
        
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (showBar) {
                [UIView setAnimationsEnabled:NO];
                if (fromVC && [fromConfig isVisible]) {
                    CGRect barFrame = [fromVC barFrameForNavigationBar:self.naviBar];
                    if (!CGRectIsNull(barFrame)) {
                        [self.fromNaviBar updateToolBarConfig:fromConfig];
                        self.fromNaviBar.frame = barFrame;
                        [fromVC.view addSubview:self.fromNaviBar];
                    }
                }
                
                if (toVC && [toConfig isVisible]) {
                    CGRect barFrame = [toVC barFrameForNavigationBar:self.naviBar];
                    if (!CGRectIsNull(barFrame)) {
                        if (toVC.extendedLayoutIncludesOpaqueBars ||
                            toConfig.translucent) {
                            barFrame.origin.y = toVC.view.bounds.origin.y;
                        }
                        [self.toNaviBar updateToolBarConfig:toConfig];
                        self.toNaviBar.frame = barFrame;
                        [toVC.view addSubview:self.toNaviBar];
                    }
                }
                
                [toVC.view addObserver:self
                            forKeyPath:NSStringFromSelector(@selector(bounds))
                               options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                               context:"updateToNaviBarFrame"];
                
                [UIView setAnimationsEnabled:YES];
            }
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if ([context isCancelled]) {
                [self clearView];
                [self.naviBar updateNaviBarConfig:fromConfig];
                
                if (fromConfig.hidden != navigationController.navigationBarHidden) {
                    [navigationController setNavigationBarHidden:toConfig.hidden animated:animated];
                }
            }
            
            if (showBar) {
                [toVC.view removeObserver:self
                               forKeyPath:NSStringFromSelector(@selector(bounds))
                                  context:"updateToNaviBarFrame"];
            }
        }];
        
        void (^popInteractionEndBlock)(id<UIViewControllerTransitionCoordinatorContext>) =
        ^(id<UIViewControllerTransitionCoordinatorContext> context){
            if ([context isCancelled]) {
                [self.naviBar updateBarStyle:fromConfig.barStyle
                                           tintColor:fromConfig.tintColor];
            }
        };
        
        if (@available(iOS 10,*)) {
            [navigationController.transitionCoordinator notifyWhenInteractionChangesUsingBlock:popInteractionEndBlock];
        } else {
            [navigationController.transitionCoordinator notifyWhenInteractionEndsUsingBlock:popInteractionEndBlock];
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self clearView];
    IBNaviConfig *showConfig = viewController.config ? viewController.config : self.defaultConfig;
    [self.naviBar updateNaviBarConfig:showConfig];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (strcmp(context, "updateToNaviBarFrame") == 0) {
        UIView *view = (UIView*)object;
        
        if (self.toNaviBar.superview == view) {
            CGRect barFrame = self.toNaviBar.frame;
            
            CGRect old = [change[NSKeyValueChangeOldKey] CGRectValue];
            CGRect new = [change[NSKeyValueChangeNewKey] CGRectValue];
            CGFloat offset = new.origin.y - old.origin.y;
            if (offset != 0) {
                barFrame.origin.y += offset;
                self.toNaviBar.frame = barFrame;
            }
        }
    }
}
#pragma mark - 私有方法

BOOL isImageEqual(UIImage *fromImage, UIImage *toImage) {
    NSData *fromImageData = UIImagePNGRepresentation(fromImage);
    NSData *toImageData = UIImagePNGRepresentation(toImage);
    BOOL result = [fromImageData isEqual:toImageData];
    return result;
}

BOOL shouldShow(IBNaviConfig *fromConfig, IBNaviConfig *toConfig) {
    if (fromConfig.hidden || toConfig.hidden) {
        return NO;
    }
    
    if (fromConfig.transparent != toConfig.transparent ||
        fromConfig.translucent != toConfig.translucent) {
        return YES;
    }


    if (fromConfig.backgroundImage && toConfig.backgroundImage) {
        if (fromConfig.backgroundImgID && toConfig.backgroundImgID) {
            return ![fromConfig.backgroundImgID isEqualToString:toConfig.backgroundImgID];
        }
        // 都有图片，并且是同一张图片
        if (isImageEqual(fromConfig.backgroundImage, toConfig.backgroundImage)) {
            return NO;
        }
    }
    
    // 都没图片，并且颜色相同
    if (CGColorEqualToColor(fromConfig.backgroundColor.CGColor, toConfig.backgroundColor.CGColor)) {
        return NO;
    }
    
    return YES;
}

- (void)clearView {
    [self.fromNaviBar removeFromSuperview];
    [self.toNaviBar removeFromSuperview];
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

- (UIToolbar *)fromNaviBar {
    if (!_fromNaviBar) {
        _fromNaviBar = [[UIToolbar alloc] init];
    }
    return _fromNaviBar;
}

- (UIToolbar *)toNaviBar {
    if (!_toNaviBar) {
        _toNaviBar = [[UIToolbar alloc] init];
    }
    return _toNaviBar;
}

- (IBNaviConfig *)defaultConfig {
    if (!_defaultConfig) {
        _defaultConfig = [[IBNaviConfig alloc] initWithBarOptions:IBNaviBarOptionDefault tintColor:nil backgroundColor:nil backgroundImage:nil backgroundImgID:nil];
    }
    return _defaultConfig;
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
