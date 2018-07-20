//
//  IBNavigationController.h
//  IBApplication
//
//  Created by Bowen on 2018/7/7.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBNaviBar.h"

@class IBModelController;

@interface IBNaviController : UINavigationController

/** 自定义导航栏 */
@property (nonatomic, readonly, strong) IBNaviBar *naviBar;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController naviBar:(Class)naviBarClass;

- (void)updateNavigationBarForViewController:(IBModelController *)vc;
- (void)updateNavigationBarAlphaForViewController:(IBModelController *)vc;
- (void)updateNavigationBarColorOrImageForViewController:(IBModelController *)vc;
- (void)updateNavigationBarShadowIAlphaForViewController:(IBModelController *)vc;

@end
