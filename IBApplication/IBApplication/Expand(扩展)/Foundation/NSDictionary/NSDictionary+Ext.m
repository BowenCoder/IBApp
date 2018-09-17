//
//  NSDictionary+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/9/17.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSDictionary+Ext.h"

@implementation NSDictionary (Ext)

- (NSNumber *)numberForKey:(NSString *)keyPath {
    return [self _valueFromDictionary:self
                          withKeyPath:keyPath
                          classVerify:[NSNumber class]];
}

- (NSString *)stringForKey:(NSString *)keyPath {
    return [self _valueFromDictionary:self
                          withKeyPath:keyPath
                          classVerify:[NSString class]];
}

- (NSDictionary *)dictionaryForKey:(NSString *)keyPath {
    return [self _valueFromDictionary:self
                          withKeyPath:keyPath
                          classVerify:[NSDictionary class]];
}

- (NSArray *)arrayForKey:(NSString *)keyPath {
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
