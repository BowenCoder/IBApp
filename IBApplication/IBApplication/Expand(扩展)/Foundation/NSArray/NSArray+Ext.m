//
//  NSArray+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSArray+Ext.h"
#import "MBLogger.h"

@implementation NSArray (Ext)

- (id)mb_objectAtIndex:(NSUInteger)index {
    
    return [self mb_containsIndex:index] ? [self objectAtIndex:index] : nil;
}

- (BOOL)mb_containsIndex:(NSUInteger)index {
    return index < [self count];
}

@end

@implementation NSMutableArray (Ext)

- (BOOL)mb_addObject:(id)object {
    
    if (!object) {
        MBLog( @"the object to be added is nil %@",[NSThread callStackSymbols]);
        return NO;
    }
    if ([object isKindOfClass:[NSNull class]]) {
        MBLog( @"the object to be added is NSNull %@",[NSThread callStackSymbols]);
        return NO;
    }
    [self addObject:object];
    return YES;
}

- (BOOL)mb_insertObject:(id)object atIndex:(NSUInteger)index {
    
    if (index > [self count]) {
        MBLog( @"the index to be inserted is out of array boundary %@",[NSThread callStackSymbols]);
        return NO;
    } else {
        if (!object) {
            MBLog( @"the object to be inserted is nil %@",[NSThread callStackSymbols]);
            return NO;
        }
        if ([object isKindOfClass:[NSNull class]]) {
            MBLog( @"the object to be inserted is NSNull %@",[NSThread callStackSymbols]);
            return NO;
        }
        [self insertObject:object atIndex:index];
        return YES;
    }
}

- (BOOL)mb_removeObjectAtIndex:(NSUInteger)index {
    
    if (index >= [self count]) {
        MBLog( @"the index to be removed is out of array boundary %@",[NSThread callStackSymbols]);
        return NO;
    }
    [self removeObjectAtIndex:index];
    return YES;
}

- (BOOL)mb_replaceObjectAtIndex:(NSUInteger)index withObject:(id)object {
    
    if (index > [self count]) {
        MBLog( @"the index to be replaced is out of array boundary %@",[NSThread callStackSymbols]);
        return NO;
    } else {
        if (!object) {
            MBLog( @"the object to be replaced is nil %@",[NSThread callStackSymbols]);
            return NO;
        }
        if ([object isKindOfClass:[NSNull class]]) {
            MBLog( @"the object to be replaced is NSNull %@",[NSThread callStackSymbols]);
            return NO;
        }
        [self replaceObjectAtIndex:index withObject:object];
        return YES;
    }
}

- (BOOL)mb_exchangeObjectAtIndex:(NSUInteger)fromIndex withObjectAtIndex:(NSUInteger)toIndex {
    if ([self count] != 0 && toIndex != fromIndex
        && fromIndex < [self count] && toIndex < [self count]) {
        [self exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
        return YES;
    } else {
        MBLog( @"the index to be exchanged is out of array boundary %@",[NSThread callStackSymbols]);
        return NO;
    }
}

@end
