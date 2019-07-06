//
//  NSDictionary+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/9/17.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSDictionary+Ext.h"
#import "MBLogger.h"

@implementation NSDictionary (Ext)

- (NSNumber *)mb_numberForKey:(NSString *)keyPath {
    return [self _valueFromDictionary:self
                          withKeyPath:keyPath
                          classVerify:[NSNumber class]];
}

- (NSString *)mb_stringForKey:(NSString *)keyPath {
    return [self _valueFromDictionary:self
                          withKeyPath:keyPath
                          classVerify:[NSString class]];
}

- (NSDictionary *)mb_dictionaryForKey:(NSString *)keyPath {
    return [self _valueFromDictionary:self
                          withKeyPath:keyPath
                          classVerify:[NSDictionary class]];
}

- (NSArray *)mb_arrayForKey:(NSString *)keyPath {
    return [self _valueFromDictionary:self
                          withKeyPath:keyPath
                          classVerify:[NSArray class]];
}

#pragma mark - Private Methods

- (id)_valueFromDictionary:(NSDictionary *)dict
               withKeyPath:(NSString *)keyPath
               classVerify:(Class)cls {
    if (!dict || !keyPath) {
        return nil;
    }
    id p;
    @try {
        p = [dict valueForKeyPath:keyPath];
        if (![p isKindOfClass:cls]) {
            p = nil;
        }
    }
    @catch (NSException *exception) {
        p = nil;
    }
    @finally {
        return p;
    }
    return nil;
}


@end


@implementation NSMutableDictionary (Ext)

- (void)mb_setObject:(id)value forKey:(id)key
{
    if (!value || !key || value == [NSNull null] || key == [NSNull null]) {
        MBLog( @"the object to be setted is failed %@",[NSThread callStackSymbols]);
        return;
    }
    
    if ([self respondsToSelector:@selector(setObject:forKey:)]) {
        [self setObject:value forKey:key];
    }
}

@end
