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

@implementation IBHelper (NSDataHelper)

/**
 *  是否空数据
 *
 *  @param data 数据
 *
 *  @return 如果数据为nil或者长度为0返回YES
 */
+ (BOOL)isEmptyData:(NSData *)data {
    
    if ([data isKindOfClass:[NSNull class]] || data == nil || [data length] < 1) {
        return YES;
    } else {
        return NO;
    }
}


@end

@implementation IBHelper (NSDictionaryHelper)

/**
 *  是否空字典
 *
 *  @param dict 字典
 *
 *  @return 如果字典为nil或者元素个数为0返回YES
 */
+ (BOOL)isEmptyDic:(NSDictionary *)dict {
    
    if (dict == nil || [dict isKindOfClass:[NSNull class]] || dict.allKeys == nil  || dict.allKeys.count == 0) {
        return YES;
    } else {
        return NO;
    }
}

@end

@implementation IBHelper (NSArrayHelper)

/**
 *  是否空数组
 *
 *  @param array 数组
 *
 *  @return 如果数组为nil或者元素个数为0返回YES
 */
+ (BOOL)isEmptyArray:(NSArray *)array {
    
    if (array != nil && ![array isKindOfClass:[NSNull class]] &&
        [array isKindOfClass:[NSArray class]] && [array count] != 0) {
        return NO;
    } else {
        return YES;
    }
}

@end


@implementation IBHelper (NSStringHelper)

/**
*  是否空字符串
*
*  @param string 字符串
*
*  @return 如果字符串为nil或者长度为0返回YES
*/
+ (BOOL)isEmptyString:(NSString *)string {
    
    if (![string isKindOfClass:[NSString class]]) {
        return TRUE;
    }else if (string == nil) {
        return TRUE;
    }else if(!string) {
        // null object
        return TRUE;
    } else if(string == NULL) {
        // null object
        return TRUE;
    } else if([string isEqualToString:@"NULL"]) {
        // null object
        return TRUE;
    }else if([string isEqualToString:@"(null)"]){
        return TRUE;
    }else{
        //  使用whitespaceAndNewlineCharacterSet删除周围的空白字符串
        //  然后在判断首位字符串是否为空
        NSString *trimedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0) {
            // empty string
            return TRUE;
        } else {
            // is neither empty nor null
            return FALSE;
        }
    }
}

@end

