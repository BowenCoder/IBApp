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

#pragma mark - 自定义外观

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.effectView.frame = self.effectView.superview.bounds;
    self.backgroundImgView.frame = self.backgroundImgView.superview.bounds;
    self.shadowImgView.frame = CGRectMake(0, CGRectGetHeight(self.shadowImgView.superview.bounds) - 0.5, CGRectGetWidth(self.shadowImgView.superview.bounds), 0.5);
}

- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        [super setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _effectView.userInteractionEnabled = NO;
        _effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[self.subviews firstObject] insertSubview:_effectView atIndex:0];

    }
    return _effectView;
}

- (UIImageView *)backgroundImgView {
    if (!_backgroundImgView) {
        _backgroundImgView = [[UIImageView alloc] init];
        _backgroundImgView.userInteractionEnabled = NO;
        _backgroundImgView.contentScaleFactor = 1;
        _backgroundImgView.contentMode = UIViewContentModeScaleToFill;
        _backgroundImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[self.subviews firstObject] insertSubview:_backgroundImgView aboveSubview:self.effectView];
    }
    return _backgroundImgView;
}

- (UIImageView *)shadowImgView {
    if (!_shadowImgView) {
        [super setShadowImage:[UIImage new]];
        _shadowImgView = [[UIImageView alloc] init];
        _shadowImgView.userInteractionEnabled = NO;
        _shadowImgView.contentScaleFactor = 1;
        [[self.subviews firstObject] insertSubview:_shadowImgView aboveSubview:self.backgroundImgView];
    }
    return _shadowImgView;
}


@end

#pragma clang diagnostic pop

