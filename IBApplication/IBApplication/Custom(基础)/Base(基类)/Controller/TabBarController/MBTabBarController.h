//
//  MBTabBarController.h
//  IBApplication
//
//  Created by Bowen on 2018/7/9.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBTabBar.h"

@interface MBTabBarController : UITabBarController

@property (nonatomic, readonly, strong) MBTabBar *customTabBar;

/// 使用自定义标签栏调用
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers itemModels:(NSArray<MBTabBarItemModel *> *)itemModels;

@end
