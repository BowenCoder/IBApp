//
//  NSObject+Ext.m
//  IBApplication
//
//  Created by Bowen on 2019/5/15.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "NSObject+Ext.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (Ext)

- (BOOL)fb_overrideMethod:(SEL)selector superclass:(Class)superclass
{
    return [NSObject fb_overrideMethod:selector currentClass:self.class superclass:superclass];
}

+ (BOOL)fb_overrideMethod:(SEL)selector currentClass:(Class)currentClass superclass:(Class)superclass
{
    if (![currentClass isSubclassOfClass:superclass]) {
        return NO;
    }
    
    if (![superclass instancesRespondToSelector:selector]) {
        return NO;
    }
    
    Method superclassMethod = class_getInstanceMethod(superclass, selector);
    Method instanceMethod = class_getInstanceMethod(currentClass, selector);
    if (!instanceMethod || instanceMethod == superclassMethod) {
        return NO;
    }
    return YES;
}

- (id)fb_msgSendSuper:(SEL)aSelector
{
    struct objc_super superclass;
    superclass.receiver = self;
    superclass.super_class = class_getSuperclass(object_getClass(self));
    
    id (*objc_superAllocTyped)(struct objc_super *, SEL) = (void *)&objc_msgSendSuper;
    return (*objc_superAllocTyped)(&superclass, aSelector);
}

- (id)fb_msgSendSuper:(SEL)aSelector withObject:(nullable id)object
{
    struct objc_super superclass;
    superclass.receiver = self;
    superclass.super_class = class_getSuperclass(object_getClass(self));
    
    id (*objc_superAllocTyped)(struct objc_super *, SEL, ...) = (void *)&objc_msgSendSuper;
    return (*objc_superAllocTyped)(&superclass, aSelector, object);
}

- (id)fb_performSelector:(SEL)selector withArguments:(nullable void *)firstArgument, ...
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    if (firstArgument) {
        va_list valist;
        va_start(valist, firstArgument);
        [invocation setArgument:firstArgument atIndex:2];// 0->self, 1->_cmd
        
        void *currentArgument;
        NSInteger index = 3;
        while ((currentArgument = va_arg(valist, void *))) {
            [invocation setArgument:currentArgument atIndex:index];
            index++;
        }
        va_end(valist);
    }
    
    [invocation invoke];
    
    const char *typeEncoding = method_getTypeEncoding(class_getInstanceMethod(object_getClass(self), selector));
    if (strncmp(typeEncoding, "@", 1) == 0) {
        __unsafe_unretained id returnValue;
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }
    return nil;
}

- (void)fb_performOriginalSelector:(SEL)selector param:(id)param
 {
    unsigned int count;
    unsigned int index = 0;
    
    // 获得指向该类所有方法的指针
    Method *methods = class_copyMethodList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        // 获得该类的一个方法指针
        Method method = methods[i];
        // 获取方法
        SEL methodSEL = method_getName(method);
        if (methodSEL == selector) {
            index = i;
        }
    }
    SEL fontSEL = method_getName(methods[index]);
    IMP fontIMP = method_getImplementation(methods[index]);
    ((void (*)(id, SEL, id))fontIMP)(self,fontSEL,param);
    
    free(methods);
}

@end
