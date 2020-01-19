//
//  MBAutoTracker.m
//  IBApplication
//
//  Created by Bowen on 2020/1/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBAutoTracker.h"
#import "RSSwizzle.h"
#import "UIView+TrackData.h"
#import "MBAutoTrackerUpload.h"

@implementation MBAutoTracker

+ (void)load
{
    [self hookApplicationEvent];
    [self hookTapGesture];
}

+ (void)hookApplicationEvent
{
    RSSwizzleInstanceMethod([UIApplication class],
                            @selector(sendAction:to:from:forEvent:),
                            RSSWReturnType(BOOL),
                            RSSWArguments(SEL action, id target, id sender, UIEvent *event),
                            RSSWReplacement({
        __block BOOL touchEnd = NO;
        if (event && event.allTouches.count > 0) {
            [event.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
                if (obj.phase == UITouchPhaseEnded) {
                    touchEnd = YES;
                    *stop = YES;
                }
            }];
        }
        if (touchEnd) {
            NSString *viewPath = [UIView viewPathForSender:sender];
            [MBAutoTrackerUpload trackViewPath:viewPath];
        }
        return RSSWCallOriginal(action, target, sender, event);
        
    }), RSSwizzleModeAlways, "app.trackdata.application.sendAction");
}

+ (void)hookTapGesture
{
    [RSSwizzle swizzleInstanceMethod:@selector(touchesEnded:withEvent:) inClass:[UIGestureRecognizer class] newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
        return ^(__unsafe_unretained UIGestureRecognizer *gesture, NSSet<UITouch *> * touches, UIEvent *event){
            
            void (*originalIMP)(__unsafe_unretained id, SEL, NSSet<UITouch *> *, UIEvent *);
            originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
            originalIMP(self, @selector(touchesEnded:withEvent:), touches, event);
            
            __block BOOL touchEnd = NO;
            if (event && event.allTouches.count > 0) {
                [event.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
                    if (obj.phase == UITouchPhaseEnded) {
                        touchEnd = YES;
                        *stop = YES;
                    }
                }];
            }
            if (touchEnd) {
                NSString *viewPath = [UIView viewPathForSender:gesture.view];
                [MBAutoTrackerUpload trackViewPath:viewPath];
            }
        };
    } mode:RSSwizzleModeAlways key:"app.trackdata.tap.touchesEnded"];
}

@end
