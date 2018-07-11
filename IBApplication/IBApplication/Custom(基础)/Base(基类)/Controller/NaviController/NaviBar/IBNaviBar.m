//
//  IBNaviBar.m
//  IBApplication
//
//  Created by Bowen on 2018/7/8.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBNaviBar.h"
#import "IBImage.h"
#import "IBApp.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface IBNaviBar ()

@end

@implementation IBNaviBar

- (void)setGlobalBarTintColor:(UIColor *)globalBarTintColor {
    _globalBarTintColor = globalBarTintColor;
    if ([IBNaviBar appearance].clipsToBounds) {
        [self hiddenBarBottomLine:NO];
    }
    if (self.lucencyBar) {
        [[IBNaviBar appearance] setBackgroundImage:[IBImage imageWithColor:globalBarTintColor] forBarMetrics:UIBarMetricsDefault];
    } else {
        [[IBNaviBar appearance] setBarTintColor:globalBarTintColor];
    }
}

- (void)setGlobalTintColor:(UIColor *)globalTintColor {
    _globalTintColor = globalTintColor;
    [[IBNaviBar appearance] setTintColor:globalTintColor];
}

- (void)setLucencyBar:(BOOL)lucencyBar {
    _lucencyBar = lucencyBar;
    [[IBNaviBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self hiddenBarBottomLine:YES];
}

- (void)hiddenBarBottomLine:(BOOL)hidden {
    [IBNaviBar appearance].clipsToBounds = hidden;
}


+ (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)fontSize {
    UINavigationBar *bar;
    if (APPSystemVersion > 9) {
        bar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[UINavigationController class]]];
    } else {
        bar = [UINavigationBar appearanceWhenContainedIn:[UINavigationController class], nil];
    }
    [bar setTitleTextAttributes:@{
                                  NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                  NSForegroundColorAttributeName : color
                                  }];
}

/** 设置按钮的颜色、大小 */
+ (void)setItemTitleColor:(UIColor *)color fontSize:(CGFloat)fontSize {
    
    UIBarButtonItem *item;
    if (APPSystemVersion > 9) {
        item = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationController class]]];
    } else {
        item = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationController class], nil];
    }
    
    NSDictionary *attrs = @{
                            NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                            NSForegroundColorAttributeName : color
                            };
    [item setTitleTextAttributes:attrs forState:UIControlStateNormal];

}

@end

#pragma clang diagnostic pop

