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

- (NSString *)JSONString {
    
    NSString *json = nil;
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (!error) {
        json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return json;
    } else {
        return error.localizedDescription;
    }
}

@end

@implementation NSMutableArray (Ext)

- (BOOL)addObjectOrNil:(id)anObject {
    
    if (!anObject) {
        return NO;
    }
    [self addObject:anObject];
    return YES;
}

- (BOOL)insertObjectOrNil:(id)anObject atIndex:(NSUInteger)index {
    
    if (!anObject || index > [self count]) {
        return NO;
    }
    [self insertObject:anObject atIndex:index];
    return YES;
}

- (BOOL)removeObjectOrNilAtIndex:(NSUInteger)index {
    
    if (index >= [self count]) {
        return NO;
    }
    [self removeObjectAtIndex:index];
    return YES;
}

- (BOOL)replaceObjectAtIndex:(NSUInteger)index withObjectOrNil:(id)anObject {
    
    if (!anObject || index >= [self count]) {
        return NO;
    }
    [self replaceObjectAtIndex:index withObject:anObject];
    return YES;
}


@end
