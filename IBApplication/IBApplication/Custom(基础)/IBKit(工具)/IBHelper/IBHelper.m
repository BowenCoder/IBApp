//
//  IBHelper.m
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBHelper.h"

@implementation IBHelper

/**
 *  @brief  NSData 转成UTF8 字符串
 *
 *  @param data 二进制
 *
 *  @return 转成UTF8 字符串
 */
+ (NSString *)UTF8String:(NSData *)data {
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

/**
 *  @brief NSDictionary转换成JSON字符串
 *
 *  @param dict 字典
 *
 *  @return  JSON字符串
 */
+ (NSString *)JSONString:(NSDictionary *)dict {
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (jsonData == nil) {
#ifdef DEBUG
        NSLog(@"fail to get JSON from dictionary: %@, error: %@", self, error);
#endif
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

/**
 *  @brief  将url参数转换成NSDictionary
 *
 *  @param query url参数
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)dictionaryWithURLQuery:(NSString *)query {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *parameters = [query componentsSeparatedByString:@"&"];
    for(NSString *parameter in parameters) {
        NSArray *contents = [parameter componentsSeparatedByString:@"="];
        if([contents count] == 2) {
            NSString *key = [contents objectAtIndex:0];
            NSString *value = [contents objectAtIndex:1];
            value = [value stringByRemovingPercentEncoding];
            
            if (key && value) {
                [dict setObject:value forKey:key];
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

/**
 *  @brief  将NSDictionary转换成url参数字符串
 *
 *  @param  params url参数
 *
 *  @return url 参数字符串
 */
+ (NSString *)URLQueryString:(NSDictionary *)params {
    
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in [params allKeys]) {
        if ([string length]) {
            [string appendString:@"&"];
        }
        CFStringRef escaped = (__bridge CFStringRef)([[[params objectForKey:key] description] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]);
        [string appendFormat:@"%@=%@", key, escaped];
        CFRelease(escaped);
    }
    return string;
}

@end


