//
//  UIResponder+IBPopup.m
//  IBPopup
//
//  Created by Bowen on 2018/8/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIResponder+IBPopup.h"
#import <objc/runtime.h>

NSString *const IBPopupFirstResponderDidChangeNotification = @"IBPopupFirstResponderDidChangeNotification";

@implementation UIResponder (IBPopup)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(becomeFirstResponder) toSelector:@selector(_becomeFirstResponder)];
    });
}

+ (void)swizzleSelector:(SEL)originalSelector toSelector:(SEL)swizzledSelector
{
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (BOOL)_becomeFirstResponder
{
    BOOL accepted = [self _becomeFirstResponder];
    if (accepted) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IBPopupFirstResponderDidChangeNotification object:self];
    }
    return accepted;
}

@end
