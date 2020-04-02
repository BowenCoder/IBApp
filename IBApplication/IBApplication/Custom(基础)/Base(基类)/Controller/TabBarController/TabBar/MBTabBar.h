//
//  MBTabBar.h
//  IBApplication
//
//  Created by Bowen on 2018/7/19.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBTabBarItem.h"

@class MBTabBar;

@protocol MBTabBarDelegate <NSObject >

- (void)tabBar:(MBTabBar *)tabbar selectIndex:(NSInteger)index;

@end


@interface MBTabBar : UIView

// 代理
@property (nonatomic, weak) id <MBTabBarDelegate> delegate;

// MBTabBarItemModel数组
@property (nonatomic, strong) NSArray <MBTabBarItemModel *> *itemModels;

// tabbar背景色
@property (nonatomic, strong) UIColor *backgroundColor;

// tabbar背景图
@property (nonatomic, strong) UIImage *backgroundImage;

// MBTabBarItem数组
@property (nonatomic, readonly, strong) NSArray <MBTabBarItem *> *tabBarItems;

// 获取当前选中下标
@property (nonatomic, assign) NSInteger selectIndex;

// 当前选中的 TabBar
@property (nonatomic, strong) MBTabBarItem *currentSelectItem;

// 重载构造创建方法
- (instancetype)initWithTabBarItemModels:(NSArray <MBTabBarItemModel *> *)itemModels;

// 设置角标
- (void)setBadge:(NSString *)badge index:(NSUInteger)index;

// 是否触发设置的动画效果
- (void)setSelectIndex:(NSInteger)selectIndex animation:(BOOL )animation;

// 进行item子视图重新布局，最好推荐在TabBarVC中的-viewDidLayoutSubviews中执行，可以达到自动布局的效果
- (void)viewDidLayoutItems;

@end
