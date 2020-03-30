//
//  UIResponder+Ext.m
//  IBApplication
//
//  Created by Bowen on 2020/3/30.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "UIResponder+Ext.h"
#import "RSSwizzle.h"
#import <objc/runtime.h>

@implementation UIResponder (Ext)

+ (void)load
{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [RSSwizzle swizzleInstanceMethod:@selector(becomeFirstResponder) inClass:UIResponder.class newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
//            return ^BOOL(UIResponder *responder){
//                responder.fb_isFirstResponder = YES;
//                BOOL (*originalIMP)(id, SEL) = (BOOL (*)(id, SEL))[swizzleInfo getOriginalImplementation];
//                return originalIMP(self, swizzleInfo.selector);
//            };
//        } mode:RSSwizzleModeAlways key:"app.bowen.responder.become"];
//        
//        [RSSwizzle swizzleInstanceMethod:@selector(resignFirstResponder) inClass:UIResponder.class  newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
//            return ^BOOL(UIResponder *responder){
//                responder.fb_isFirstResponder = NO;
//                BOOL (*originalIMP)(id, SEL) = (BOOL (*)(id, SEL))[swizzleInfo getOriginalImplementation];
//                return originalIMP(self, @selector(resignFirstResponder));
//            };
//        } mode:RSSwizzleModeAlways key:@"app.bowen.responder.resign"];
//    });
}

- (void)setFb_isFirstResponder:(BOOL)fb_isFirstResponder
{
    objc_setAssociatedObject(self, @selector(fb_isFirstResponder), @(fb_isFirstResponder), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)fb_isFirstResponder
{
    return [objc_getAssociatedObject(self, @selector(fb_isFirstResponder)) boolValue];
}

@end
