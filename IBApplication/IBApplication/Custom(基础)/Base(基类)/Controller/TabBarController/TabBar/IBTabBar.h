//
//  IBTabBar.h
//  IBApplication
//
//  Created by Bowen on 2018/7/19.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBTabBarItem.h"

@class IBTabBar;

@protocol IBTabBarDelegate <NSObject >

- (void)tabBar:(IBTabBar *)tabbar selectIndex:(NSInteger)index;

@end


@interface IBTabBar : UIView

// 代理
@property (nonatomic, weak) id <IBTabBarDelegate> delegate;

// IBTabBarItemModel数组
@property (nonatomic, strong) NSArray <IBTabBarItemModel *> *itemModels;

// tabbar背景色
@property (nonatomic, strong) UIColor *backgroundColor;

// tabbar背景图
@property (nonatomic, strong) UIImage *backgroundImage;

// IBTabBarItem数组
@property (nonatomic, readonly, strong) NSArray <IBTabBarItem *> *tabBarItems;

// 获取当前选中下标
@property (nonatomic, assign) NSInteger selectIndex;

// 当前选中的 TabBar
@property (nonatomic, strong) IBTabBarItem *currentSelectItem;

// 重载构造创建方法
- (instancetype)initWithTabBarItemModels:(NSArray <IBTabBarItemModel *> *)itemModels;

// 设置角标
- (void)setBadge:(NSString *)badge index:(NSUInteger)index;

// 是否触发设置的动画效果
- (void)setSelectIndex:(NSInteger)selectIndex animation:(BOOL )animation;

// 进行item子视图重新布局，最好推荐在TabBarVC中的-viewDidLayoutSubviews中执行，可以达到自动布局的效果
- (void)viewDidLayoutItems;

@end
