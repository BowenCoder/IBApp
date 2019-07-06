//
//  IBSerialization.m
//  IBApplication
//
//  Created by BowenCoder on 2019/7/6.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBSerialization.h"

@implementation IBSerialization

+ (NSData *)serializeJsonDataWithDict:(NSDictionary *)dict
{
    if (![NSJSONSerialization isValidJSONObject:dict]) {
        return nil;
    }
    return [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
}

+ (NSString *)serializeJsonStringWithDict:(NSDictionary *)dict
{
    NSData *data = [IBSerialization serializeJsonDataWithDict:dict];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSArray *)unSerializeArrayWithJsonData:(NSData *)data error:(NSError **)error
{
    if (!data) {
        return nil;
    }
    id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    if ([object isKindOfClass:[NSArray class]]) {
        NSArray *array = object;
        return array;
    } else {
        return nil;
    }
}

+ (NSArray *)unSerializeArrayWithJsonString:(NSString *)jsonStr error:(NSError **)error
{
    if (!jsonStr) {
        return nil;
    }
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    id object = [IBSerialization unSerializeArrayWithJsonData:data error:error];
    if ([object isKindOfClass:[NSArray class]]) {
        NSArray *array = object;
        return array;
    } else {
        return nil;
    }
}

+ (NSDictionary *)unSerializeWithJsonData:(NSData *)data error:(NSError **)error
{
    if (!data) {
        return nil;
    }
    id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = object;
        return dict;
    } else {
        return nil;
    }
}

+ (NSDictionary *)unSerializeWithJsonString:(NSString *)jsonStr error:(NSError **)error
{
    if (!jsonStr) {
        return nil;
    }
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    id object = [IBSerialization unSerializeWithJsonData:data error:error];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = object;
        return dict;
    } else {
        return nil;
    }
}

@end
