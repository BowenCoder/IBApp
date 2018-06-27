//
//  NSEncode.h
//  IBApplication
//
//  Created by Bowen on 2018/6/26.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

//Hmac加密
typedef NS_ENUM(NSInteger, NSEncodeHmacOption) {
    NSEncodeHmacOptionSHA1,
    NSEncodeHmacOptionMD5,
    NSEncodeHmacOptionSHA256,
    NSEncodeHmacOptionSHA384,
    NSEncodeHmacOptionSHA512,
    NSEncodeHmacOptionSHA224
};

//hash加密
typedef NS_ENUM(NSInteger, NSEncodeHashOption) {
    NSEncodeHashOptionSHA1,
    NSEncodeHashOptionMD5,
    NSEncodeHashOptionSHA256,
    NSEncodeHashOptionSHA384,
    NSEncodeHashOptionSHA512,
    NSEncodeHashOptionSHA224
};

/**
 对NSDate和NSString编码(加密解密)
 */
@interface NSEncode : NSObject

/**
 *  @brief  NSData 转成UTF8 字符串
 *
 *  @param data 二进制
 *
 *  @return 转成UTF8 字符串
 */
+ (NSString *)UTF8String:(NSData *)data;

/**
 *  @brief NSDictionary转换成JSON字符串
 *
 *  @param dict 字典
 *
 *  @return  JSON字符串
 */
+ (NSString *)JSONString:(NSDictionary *)dict;

/**
 *  @brief  将url参数转换成NSDictionary
 *
 *  @param query url参数
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)dictionaryWithURLQuery:(NSString *)query;

/**
 *  @brief  将NSDictionary转换成url参数字符串
 *
 *  @param  params url参数
 *
 *  @return url 参数字符串
 */
+ (NSString *)URLQueryString:(NSDictionary *)params;

@end

@interface NSEncode (MD5)

//计算NSString的MD5值
+ (NSString *)md5WithString:(NSString *)string;

//计算NSData的MD5值
+ (NSString*)md5WithData:(NSData*)data;

//计算大文件的MD5值
+ (NSString*)md5WithFile:(NSString*)path;

@end

@interface NSEncode (NSDataBase64)

/**
 *  @brief  base64字符串解码
 *
 *  @param string base64字符串
 *
 *  @return 返回解码后的data
 */
+ (NSData *)decodeBase64:(NSString *)string;

/**
 *  @brief  NSData转NSString 换行长度默认64
 *
 *  @return base64后的字符串
 */
+ (NSString *)encodeBase64:(NSData *)data;

@end

@interface NSEncode (NSDataHash)

/**
 *  @brief           键控哈希算法
 *
 *  @param data      二进制
 *  @param key       密钥
 *  @param option    算法类型
 *
 *  @return          结果
 */
+ (NSData *)hmac:(NSData *)data key:(NSString *)key option:(NSEncodeHmacOption)option;

/**
 *  @brief           哈希算法
 *
 *  @param data      二进制
 *  @param option    算法类型
 *
 *  @return          结果
 */
+ (NSData *)hash:(NSData *)data option:(NSEncodeHashOption)option;

@end

@interface NSEncode (NSDataGzip)

/**
 *  @brief  compressedData 压缩后的数据
 *
 *  @return 是否压缩
 */
+ (BOOL)isGzippedData:(NSData *)compressedData;

/**
 *  @brief  GZIP压缩 压缩级别 默认-1
 *
 *  @param  data      二进制
 *
 *  @return 压缩后的数据
 */
+ (NSData *)gzippedData:(NSData *)data;

/**
 *  @brief  GZIP解压
 *
 *  @param  data      二进制
 *
 *  @return 解压后数据
 */
+ (NSData *)gunzippedData:(NSData *)data;

@end

@interface NSEncode (NSStringEncode)

/**
 *  对url进行编码
 *
 *  @param  string url字符串
 *
 *  @return 编码好的字符串
 */
+ (NSString *)URLEncode:(NSString *)string;

/**
 *  对url进行解码
 *
 *  @param  string url字符串
 *
 *  @return 解码好的字符串
 */
+ (NSString *)URLDecode:(NSString *)string;

/**
 *  @brief  Unicode字符串转成NSString
 *
 *  @param  string Unicode字符串
 *
 *  @return Unicode字符串转成NSString
 */
+ (NSString *)transformUnicode:(NSString *)string;

/**
 *  返回Base64编码的字符串
 */
+ (NSString *)base64Encode:(NSString *)string;

/**
 *  返回Base64编码的字符串
 */
+ (NSString *)base64Decode:(NSString *)string;

/**
 *  返回sha1编码的字符串
 */
+ (NSString *)sha1:(NSString *)string;

/**
 *  返回sha256编码的字符串
 */
+ (NSString *)sha256:(NSString *)string;

/**
 *  返回sha512编码的字符串
 */
+ (NSString *)sha512:(NSString *)string;

@end

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



