//
//  IBNavigationController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/7.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBNaviController.h"

@interface IBNaviController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) UIToolbar *fromNaviBar;
@property (nonatomic, strong) UIToolbar *toNaviBar;

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
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self clearView];
    [self.naviBar applyBarConfig:viewController.config];
}

#pragma mark - 私有方法

BOOL isImageEqual(UIImage *fromImage, UIImage *toImage) {
    
    if (fromImage && toImage) {
        NSData *fromImageData = UIImagePNGRepresentation(fromImage);
        NSData *toImageData = UIImagePNGRepresentation(toImage);
        BOOL result = [fromImageData isEqual:toImageData];
        return result;
    }
    return NO;
}

BOOL shouldShow(UIViewController *vc,UIViewController *from, UIViewController *to) {
    if (vc != to ) {
        return NO;
    }
    
    if (isImageEqual(from.config.backgroundImage, to.config.backgroundImage)) {
        // 都有图片，并且是同一张图片
        if (ABS(from.config.alpha - to.config.alpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    if (CGColorEqualToColor(from.config.backgroundColor.CGColor, to.config.backgroundColor.CGColor)) {
        // 都没图片，并且颜色相同
        if (ABS(from.config.alpha - to.config.alpha) > 0.1) {
            return YES;
        }
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
