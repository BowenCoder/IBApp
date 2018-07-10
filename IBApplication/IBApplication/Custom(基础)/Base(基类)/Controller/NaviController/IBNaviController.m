//
//  IBNavigationController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/7.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBNaviController.h"

@interface IBNaviController ()

@end

@implementation IBNaviController

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

- (void)viewDidLoad {
    [super viewDidLoad];
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
