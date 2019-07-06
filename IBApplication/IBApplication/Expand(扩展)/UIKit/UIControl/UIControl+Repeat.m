//
//  UIControl+Repeat.m
//  IBApplication
//
//  Created by Bowen on 2018/8/16.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIControl+Repeat.h"
#import <objc/runtime.h>

@interface UIControl ()

@property (nonatomic, assign) NSTimeInterval acceptEventTime;

@end

@implementation UIControl (Repeat)

// 在load时执行hook
+ (void)load {
    Method before   = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method after    = class_getInstanceMethod(self, @selector(mb_sendAction:to:forEvent:));
    method_exchangeImplementations(before, after);
}

- (void)mb_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if ([NSDate date].timeIntervalSince1970 - self.acceptEventTime < self.acceptEventInterval) {
        return;
    }
    
    if (self.acceptEventInterval > 0) {
        self.acceptEventTime = [NSDate date].timeIntervalSince1970;
    }
    
    [self mb_sendAction:action to:target forEvent:event];
}

#pragma mark - associated Object

- (NSTimeInterval)acceptEventInterval {
    return  [objc_getAssociatedObject(self, @selector(acceptEventInterval)) doubleValue];
}

- (void)setAcceptEventInterval:(NSTimeInterval)acceptEventInterval {
    objc_setAssociatedObject(self, @selector(acceptEventInterval), @(acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)acceptEventTime {
    return  [objc_getAssociatedObject(self, @selector(acceptEventTime)) doubleValue];
}

- (void)setAcceptEventTime:(NSTimeInterval)acceptEventTime {
    objc_setAssociatedObject(self, @selector(acceptEventTime), @(acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
