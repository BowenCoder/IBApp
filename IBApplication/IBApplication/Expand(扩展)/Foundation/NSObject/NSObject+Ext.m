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

/*
- (void)callOriginalMethod:(SEL)selector param:(id)param {
    unsigned int count;
    unsigned int index = 0;
    
    //获得指向该类所有方法的指针
    Method *methods = class_copyMethodList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        //获得该类的一个方法指针
        Method method = methods[i];
        //获取方法
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
 */

@end
