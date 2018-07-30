//
//  IBNaviBar+Config.m
//  IBApplication
//
//  Created by Bowen on 2018/7/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBNaviBar+Config.h"
#import <objc/runtime.h>
#import "IBImage.h"

@implementation UIViewController (Config)

- (CGRect)barFrameForNavigationBar:(UINavigationBar *)navigationBar {
    
    if ([navigationBar isKindOfClass:[IBNaviBar class]]) {
        IBNaviBar *naviBar = (IBNaviBar *)navigationBar;
        UIView *backgroundView = [naviBar backgroundView];
        CGRect frame = [backgroundView.superview convertRect:backgroundView.frame toView:self.view];
        frame.origin.x = self.view.bounds.origin.x;
        //  解决根视图为scrollView的时候，Push不正常
        if ([self.view isKindOfClass:[UIScrollView class]]) {
            //  适配iPhoneX
            frame.origin.y = -([UIScreen mainScreen].bounds.size.height == 812.0 ? 88 : 64);
        }

        return frame;
    } else {
        return CGRectNull;
    }
}


- (void)setConfig:(IBNaviConfig *)config {
    objc_setAssociatedObject(self, "ib_config", config, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (IBNaviConfig *)config {
    return objc_getAssociatedObject(self, "ib_config");
}

@end


@implementation UIToolbar (Config)

- (void)updateToolBarConfig:(IBNaviConfig *)config {
    
    self.barStyle = config.barStyle;
    self.alpha = config.alpha;

    UIImage *transpanrentImage = [[UIImage alloc] init];
    if (config.transparent) {
        self.translucent = YES;
        [self setBackgroundImage:transpanrentImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    } else {
        self.translucent = config.translucent;
        UIImage *backgroundImage = config.backgroundImage;
        if (!backgroundImage && config.backgroundColor) {
            backgroundImage = [IBImage imageWithColor:config.backgroundColor];
        }
        
        [self setBackgroundImage:backgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
    
    [self setShadowImage:transpanrentImage forToolbarPosition:UIBarPositionAny];
}

@end
