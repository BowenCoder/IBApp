//
//  NSArray+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSArray+Ext.h"

@implementation NSArray (Ext)

- (id)objectOrNilAtIndex:(NSUInteger)index {
    
    return [self containsIndex:index] ? [self objectAtIndex:index] : nil;
}

- (BOOL)containsIndex:(NSUInteger)index {
    return index < [self count];
}


@end

@implementation NSMutableArray (Ext)

- (BOOL)addObjectOrNil:(id)object {
    
    if (!object) {
        NSLogger( @"the object to be added is nil");
        return NO;
    }
    if ([object isKindOfClass:[NSNull class]]) {
        NSLogger( @"the object to be added is NSNull");
        return NO;
    }
    [self addObject:object];
    return YES;
}

- (BOOL)insertObjectOrNil:(id)object atIndex:(NSUInteger)index {
    
    if (index > [self count]) {
        NSLogger( @"the index to be inserted is out of array boundary");
        return NO;
    } else {
        if (!object) {
            NSLogger( @"the object to be inserted is nil");
            return NO;
        }
        if ([object isKindOfClass:[NSNull class]]) {
            NSLogger( @"the object to be inserted is NSNull");
            return NO;
        }
        [self insertObject:object atIndex:index];
        return YES;
    }
}

- (BOOL)removeObjectOrNilAtIndex:(NSUInteger)index {
    
    if (index >= [self count]) {
        NSLogger( @"the index to be removed is out of array boundary");
        return NO;
    }
    [self removeObjectAtIndex:index];
    return YES;
}

- (BOOL)replaceObjectAtIndex:(NSUInteger)index withObjectOrNil:(id)object {
    
    if (index > [self count]) {
        NSLogger( @"the index to be replaced is out of array boundary");
        return NO;
    } else {
        if (!object) {
            NSLogger( @"the object to be replaced is nil");
            return NO;
        }
        if ([object isKindOfClass:[NSNull class]]) {
            NSLogger( @"the object to be replaced is NSNull");
            return NO;
        }
        [self replaceObjectAtIndex:index withObject:object];
        return YES;
    }
}

- (BOOL)swapObjectAtIndex:(NSUInteger)fromIndex withObjectAtIndex:(NSUInteger)toIndex {
    if ([self count] != 0 && toIndex != fromIndex
        && fromIndex < [self count] && toIndex < [self count]) {
        [self exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
        return YES;
    } else {
        NSLogger( @"the index to be exchanged is out of array boundary");
        return NO;
    }
}


@end
