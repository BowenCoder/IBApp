//
//  IBTabBarController.h
//  IBApplication
//
//  Created by Bowen on 2018/7/9.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBTabBar.h"

@interface IBTabBarController : UITabBarController

@property (nonatomic, readonly, strong) IBTabBar *customTabBar;

/// 使用自定义标签栏调用
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers itemModels:(NSArray<IBTabBarItemModel *> *)itemModels;

@end
