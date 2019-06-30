//
//  IBDebug.m
//  IBApplication
//
//  Created by Bowen on 2018/7/4.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBDebug.h"
#import "IBFPSLabel.h"
#import "UIMacros.h"

@interface IBDebug ()

@end


@implementation IBDebug

+ (void)openFPS {
    
    IBFPSLabel *fps = [[IBFPSLabel alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width-50)/2+50, 0, 60, 20)];
    if (kIphoneX) {
        fps.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width)/2-30, 26, 60, 20);
    }
    if ([UIApplication sharedApplication].keyWindow) {
        [[UIApplication sharedApplication].keyWindow addSubview:fps];
    } else {
        UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
        [window.rootViewController.view addSubview:fps];
    }
}

+ (void)closeFPS {
    
    NSArray *views = [UIApplication sharedApplication].keyWindow.subviews;
    for (UIView *view in views) {
        if ([view isKindOfClass:[IBFPSLabel class]]) {
            IBFPSLabel *fps = (IBFPSLabel *)view;
            [fps invalidate];
        }
    }
}

@end
