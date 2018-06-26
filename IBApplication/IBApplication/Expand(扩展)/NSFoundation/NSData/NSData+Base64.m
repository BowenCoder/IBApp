//
//  NSData+Base64.m
//  IBApplication
//
//  Created by Bowen on 2018/6/22.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSData+Base64.h"
#import <Availability.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation NSData (Base64)
/**
 *  @brief  base64字符串解码
 *
 *  @param string base64字符串
 *
 *  @return 返回解码后的data
 */
+ (NSData *)decodeBase64:(NSString *)string {
    
    if (![string length]) return nil;
    NSData *decoded = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        decoded = [[self alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    } else {
        decoded = [[self alloc] initWithBase64Encoding:[string stringByReplacingOccurrencesOfString:@"[^A-Za-z0-9+/=]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [string length])]];
    }
    return decoded;
}

/**
 *  @brief  NSData转string 换行长度默认64
 *
 *  @return base64后的字符串
 */
- (NSString *)encodeBase64 {
    
    return [self _base64EncodedStringWithWrapWidth:0];
}

/**
 *  @brief  NSData 转成UTF8 字符串
 *
 *  @return 转成UTF8字符串
 */
-(NSString *)UTF8String {
    
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}


/**
 *  @brief  NSData转string
 *
 *  @param wrapWidth 换行长度  76  64
 *
 *  @return base64后的字符串
 */
- (NSString *)_base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth {
    
    if (![self length]) return nil;
    NSString *encoded = nil;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 7.0) {
        encoded = [self base64Encoding];
    } else {
        switch (wrapWidth) {
            case 64: {
                return [self base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            }
            case 76: {
                return [self base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
            }
            default: {
                encoded = [self base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
            }
        }
    }
    
    if (!wrapWidth || wrapWidth >= [encoded length]) {
        return encoded;
    }
    wrapWidth = (wrapWidth / 4) * 4;
    NSMutableString *result = [NSMutableString string];
    for (NSUInteger i = 0; i < [encoded length]; i+= wrapWidth) {
        if (i + wrapWidth >= [encoded length]) {
            [result appendString:[encoded substringFromIndex:i]];
            break;
        }
        [result appendString:[encoded substringWithRange:NSMakeRange(i, wrapWidth)]];
        [result appendString:@"\r\n"];
    }
    return result;
}

@end

#pragma clang diagnostic pop
