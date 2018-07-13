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

- (void)setGlobalBarColor:(UIColor *)globalBarColor {
    _globalBarColor = globalBarColor;
    if (self.lucencyBar) {
        [self setGlobalBgImage:[IBImage imageWithColor:globalBarColor]];
    } else {
        [[IBNaviBar appearance] setBarTintColor:globalBarColor];
    }
}

- (void)setGlobalBgImage:(UIImage *)globalBgImage {
    _globalBgImage = globalBgImage;
    [[IBNaviBar appearance] setBackgroundImage:globalBgImage forBarMetrics:UIBarMetricsDefault];
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
    UIView *_barBackground = self.subviews.firstObject;
    for (UIView *view in _barBackground.subviews) {
        if (view.frame.size.height <= 1.0) {
            view.hidden = hidden;
        }
    }
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

