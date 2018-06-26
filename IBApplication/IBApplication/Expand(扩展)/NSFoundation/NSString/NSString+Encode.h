//
//  NSString+Encode.h
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 命令行测试命令
 *
 *  MD5
 *  $ echo -n abc | openssl md5
 *  SHA1
 *  $ echo -n abc | openssl sha1
 *  SHA256
 *  $ echo -n abc | openssl sha -sha256
 *  SHA512
 *  $ echo -n abc | openssl sha -sha512
 *  BASE64编码(abc)
 *  $ echo -n abc | base64
 *
 *  BASE64解码(YWJj，abc的编码)
 *  $ echo -n YWJj | base64 -D
 */

@interface NSString (Encode)

/**
 *  返回md5编码的字符串
 */
@property (nonatomic, readonly) NSString *md5String;
/**
 *  返回sha1编码的字符串
 */
@property (nonatomic, readonly) NSString *sha1String;
/**
 *  返回sha256编码的字符串
 */
@property (nonatomic, readonly) NSString *sha256String;
/**
 *  返回sha512编码的字符串
 */
@property (nonatomic, readonly) NSString *sha512String;
/**
 *  返回Base64编码的字符串
 */
@property (nonatomic, readonly) NSString *base64Encode;
/**
 *  返回Base64编码的字符串
 */
@property (nonatomic, readonly) NSString *base64Decode;


@end
