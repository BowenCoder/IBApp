//
//  NSPointerArray+Ext.m
//  IBApplication
//
//  Created by Bowen on 2020/3/30.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "NSPointerArray+Ext.h"

@implementation NSPointerArray (Ext)

- (NSUInteger)fb_indexOfPointer:(nullable void *)pointer
{
    if (!pointer) {
        return NSNotFound;
    }
    
    NSPointerArray *array = [self copy];
    for (NSUInteger i = 0; i < array.count; i++) {
        if ([array pointerAtIndex:i] == ((void *)pointer)) {
            return i;
        }
    }
    return NSNotFound;
}

- (BOOL)fb_containsPointer:(nullable void *)pointer
{
    if (!pointer) {
        return NO;
    }
    if ([self fb_indexOfPointer:pointer] != NSNotFound) {
        return YES;
    }
    return NO;
}

@end
