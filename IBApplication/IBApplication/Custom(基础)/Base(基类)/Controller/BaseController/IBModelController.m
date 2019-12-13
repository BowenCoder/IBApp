//
//  IBModelController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBModelController.h"
#import "MBProgressHUD+Ext.h"

@interface IBModelController ()


@end

@implementation IBModelController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    
}

#pragma mark - 初始化

#pragma mark - 添加控件

#pragma mark - 公开方法

#pragma mark - 网络请求

#pragma mark - 通知事件

#pragma mark - 对象事件

#pragma mark - 代理事件

#pragma mark - 其他方法

#pragma mark - 合成存取

- (IBNaviController *)naviController {
    if (self.navigationController && [self.navigationController isKindOfClass:[IBNaviController class]]) {
        return (IBNaviController *)self.navigationController;
    }
    return nil;
}

- (IBTabBarController *)tabController {
    if (self.tabBarController && [self.tabBarController isKindOfClass:[IBTabBarController class]]) {
        return (IBTabBarController *)self.tabController;
    }
    return nil;
}


@end
