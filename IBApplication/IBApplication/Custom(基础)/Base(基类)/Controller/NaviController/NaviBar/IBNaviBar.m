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
    self.hiddenLine = YES;
}

- (void)setHiddenLine:(BOOL)hiddenLine {
    _hiddenLine = hiddenLine;
    UIView *_barBackground = self.subviews.firstObject;
    for (UIView *view in _barBackground.subviews) {
        if (view.frame.size.height <= 1.0) {
            view.hidden = hiddenLine;
        }
    }
}

+ (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)fontSize {
    UINavigationBar *bar;
    if (IOS_VERSION > 900000) {
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
    if (IOS_VERSION > 900000) {
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

- (UIView *)backgroundView {
    return [self valueForKey:@"_backgroundView"];
}

- (void)updateBarStyle:(UIBarStyle)barStyle tintColor:(UIColor *)tintColor {
    self.barStyle = barStyle;
    self.tintColor = tintColor;
}

- (void)updateNaviBarConfig:(IBNaviConfig *)config {
#if DEBUG
    if (@available(iOS 11,*)) {
        NSAssert(!self.prefersLargeTitles, @"large titles is not supported");
    }
#endif
    
    [self updateBarStyle:config.barStyle tintColor:config.tintColor];
    
    if (config.alpha >= 0 && config.alpha < 1) {
        [self updateBackgroundAlpha:config.alpha];
    }
    
    UIView *backgroundView = [self backgroundView];
    UIImage *transpanrentImage = [[UIImage alloc] init];
    if (config.transparent) {
        backgroundView.alpha = 0;
        self.translucent = YES;
        [self setBackgroundImage:transpanrentImage forBarMetrics:UIBarMetricsDefault];
    } else {
        backgroundView.alpha = 1;
        self.translucent = config.translucent;
        UIImage *backgroundImage = config.backgroundImage;
        if (!backgroundImage && config.backgroundColor) {
            backgroundImage = [IBImage imageWithColor:config.backgroundColor];
        }
        [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    }
    self.shadowImage = transpanrentImage;
}

- (void)updateBackgroundAlpha:(CGFloat)alpha {
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                obj.alpha = alpha;
            });
        }
    }];
}

//- (void)setTranslationY:(CGFloat)translationY {
//    self.transform = CGAffineTransformMakeTranslation(0, translationY);
//}
//
//- (void)resetTranslation {
//    self.transform = CGAffineTransformIdentity;
//}


@end

#pragma clang diagnostic pop

