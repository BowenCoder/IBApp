//
//  NSDebug.m
//  IBApplication
//
//  Created by Bowen on 2018/7/4.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSDebug.h"
#import "NSFPSLabel.h"

@interface NSDebug ()

@end


@implementation NSDebug

+ (void)openFPS {
    
    NSFPSLabel *fps = [[NSFPSLabel alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width-50)/2+50, 0, 60, 20)];
    if (IPHONEX) {
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
        if ([view isKindOfClass:[NSFPSLabel class]]) {
            NSFPSLabel *fps = (NSFPSLabel *)view;
            [fps invalidate];
        }
    }
}

@end
