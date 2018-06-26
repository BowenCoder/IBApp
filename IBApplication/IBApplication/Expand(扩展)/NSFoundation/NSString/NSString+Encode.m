//
//  NSString+Encode.m
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSString+Encode.h"
#import "NSData+Base64.h"
#import "NSData+Hash.h"

@implementation NSString (Encode)

/**
 *  返回md5编码的字符串
 */
- (NSString *)md5String {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    data = [data hash:IBCHashAlgorithmMD5];
    return [self _convertByte:(unsigned char *)data.bytes length:data.length];
}

/**
 *  返回sha1编码的字符串
 */
- (NSString *)sha1String {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    data = [data hash:IBCHashAlgorithmSHA1];
    return [self _convertByte:(unsigned char *)data.bytes length:data.length];
}

/**
 *  返回sha256编码的字符串
 */
- (NSString *)sha256String {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    data = [data hash:IBCHashAlgorithmSHA256];
    return [self _convertByte:(unsigned char *)data.bytes length:data.length];
}

/**
 *  返回sha512编码的字符串
 */
- (NSString *)sha512String {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    data = [data hash:IBCHashAlgorithmSHA512];
    return [self _convertByte:(unsigned char *)data.bytes length:data.length];
}

- (NSString *)base64Encode {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return data.encodeBase64;
}

- (NSString *)base64Decode {
    NSData *data = [NSData decodeBase64:self];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)_convertByte:(unsigned char *)bytes length:(NSUInteger)length{
    
    NSMutableString *string = [[NSMutableString alloc] init];
    for(int i = 0; i< length; i++) {
        [string appendFormat:@"%02x", bytes[i]];
    }
    return string;
}


@end
