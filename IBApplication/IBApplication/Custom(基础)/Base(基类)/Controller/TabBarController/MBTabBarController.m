//
//  MBTabBarController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/9.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBTabBarController.h"

@interface MBTabBarController ()<MBTabBarDelegate>

@property (nonatomic, strong) MBTabBar *internalTabBar;

@end

@implementation MBTabBarController

// 先设置vc再设置customTabBar，避免遮挡
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers itemModels:(NSArray<MBTabBarItemModel *> *)itemModels {
    self.viewControllers = viewControllers;
    self.internalTabBar = [[MBTabBar alloc] init];
    self.internalTabBar.itemModels = itemModels;
    self.internalTabBar.delegate = self;
    [self.tabBar addSubview:self.internalTabBar];
}

#pragma mark - IBTabBarDelegate
// 自定义的tabBar回调点击事件给TabBarVC，TabBarVC用父类的TabBarController函数完成切换
- (void)tabBar:(MBTabBar *)tabbar selectIndex:(NSInteger)index {
    [self setSelectedIndex:index];
}

#pragma mark - 系统选中处理
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    if(self.internalTabBar) {
        self.internalTabBar.selectIndex = selectedIndex;
    }
}

#pragma mark - 布局
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.internalTabBar.frame = self.tabBar.bounds;
    [self.internalTabBar viewDidLayoutItems];
}

#pragma mark - 合成存取
- (MBTabBar *)customTabBar {
    if (self.internalTabBar) {
        return self.internalTabBar;
    }
    return nil;
}

#pragma mark - 控制屏幕旋转
- (BOOL)shouldAutorotate {
    UIViewController *vc = self.selectedViewController;
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)vc shouldAutorotate];
    }
    return vc.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *vc = self.selectedViewController;
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)vc supportedInterfaceOrientations];
    }
    return vc.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *vc = self.selectedViewController;
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)vc preferredInterfaceOrientationForPresentation];
    }
    return vc.preferredInterfaceOrientationForPresentation;
}


@end
