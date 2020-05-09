//
//  IBHelper.m
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBHelper.h"
#import "MBLogger.h"
#import "IBMacros.h"

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
+ (NSString *)jsonStringFromDict:(NSDictionary *)dict {
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error) {
        MBLog(@"fail to get JSON from dictionary: %@, error: %@", self, error);
        return error.localizedDescription;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSString *)jsonStringFromArray:(NSArray *)array {
    NSString *json = nil;
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    
    if (!error) {
        json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return json;
    } else {
        MBLog(@"fail to get JSON from dictionary: %@, error: %@", self, error);
        return error.localizedDescription;
    }
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

+ (NSDictionary *)dictionaryWithURL:(NSURL *)url {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];
    NSMutableDictionary *parm = [[NSMutableDictionary alloc] init];
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [parm setObject:obj.value forKey:obj.name];
    }];
    return parm.copy;
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
        NSString *value = [[params valueForKey:key] description];
        [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
        [string appendFormat:@"%@=%@", key, value];
    }
    return string.copy;
}

+ (NSString *)fullURL:(NSString *)url params:(NSDictionary *)params {
    
    if (kIsEmptyDict(params)) {
        return url;
    }
    
    NSMutableString *urlStr = [NSMutableString stringWithString:url];
    NSRange flag = [urlStr rangeOfString:@"?"];
    if(flag.location == NSNotFound) {
        [urlStr appendString:@"?"];
    }
    [urlStr appendString:[self URLQueryString:params]];
    
    return urlStr.copy;
}

+ (NSString *)fullURL:(NSString *)url paramStr:(NSString *)paramStr
{
    if (kIsEmptyString(url) || kIsEmptyString(paramStr)) {
        return url;
    }
    
    NSRange flag = [url rangeOfString:@"?"];
    NSRange andFlag = [url rangeOfString:@"&"];
    
    NSMutableString *tempURL = [NSMutableString string];
    [tempURL appendString:url];
    if (flag.location == NSNotFound && andFlag.location == NSNotFound) {
        [tempURL appendString:@"?"];
    } else {
        [tempURL appendString:@"&"];
    }
    [tempURL appendString:NSStringNONil(paramStr)];
    
    return tempURL.copy;
}

@end


