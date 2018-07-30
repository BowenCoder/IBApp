//
//  IBNavigationController.h
//  IBApplication
//
//  Created by Bowen on 2018/7/7.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBNaviBar.h"
#import "IBNaviBar+Config.h"

@interface IBNaviController : UINavigationController

/** 自定义导航栏 */
@property (nonatomic, readonly, strong) IBNaviBar *naviBar;

/** 自定义导航栏初始化 */
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController naviBar:(Class)naviBarClass;

- (void)updateNavBarAlphaWithOffset:(CGFloat)offset range:(CGFloat)height;

//- (void)updateNavBarOriginY:(CGFloat)offset;

@end
