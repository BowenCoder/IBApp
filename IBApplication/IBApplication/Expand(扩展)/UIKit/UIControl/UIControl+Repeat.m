//
//  UIControl+Repeat.m
//  IBApplication
//
//  Created by Bowen on 2018/8/16.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIControl+Repeat.h"
#import <objc/runtime.h>

// 因category不能添加属性，只能通过关联对象的方式。
static const char *UIControl_acceptEventInterval = "UIControl_acceptEventInterval";
static const char *UIControl_acceptEventTime = "UIControl_acceptEventTime";

@interface UIControl ()

@property (nonatomic, assign) NSTimeInterval acceptEventTime;

@end

@implementation UIControl (Repeat)

// 在load时执行hook
+ (void)load {
    Method before   = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method after    = class_getInstanceMethod(self, @selector(ib_sendAction:to:forEvent:));
    method_exchangeImplementations(before, after);
}

- (NSTimeInterval)acceptEventInterval {
    return  [objc_getAssociatedObject(self, UIControl_acceptEventInterval) doubleValue];
}

- (void)setAcceptEventInterval:(NSTimeInterval)acceptEventInterval {
    objc_setAssociatedObject(self, UIControl_acceptEventInterval, @(acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)acceptEventTime {
    return  [objc_getAssociatedObject(self, UIControl_acceptEventTime) doubleValue];
}

- (void)setAcceptEventTime:(NSTimeInterval)acceptEventTime {
    objc_setAssociatedObject(self, UIControl_acceptEventTime, @(acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)ib_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if ([NSDate date].timeIntervalSince1970 - self.acceptEventTime < self.acceptEventInterval) {
        return;
    }
    
    if (self.acceptEventInterval > 0) {
        self.acceptEventTime = [NSDate date].timeIntervalSince1970;
    }
    
    [self ib_sendAction:action to:target forEvent:event];
}

@end
