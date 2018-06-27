//
//  NSCrypto.h
//  IBApplication
//
//  Created by Bowen on 2018/6/26.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

//对称加密
typedef NS_ENUM(NSInteger, NSEncryptOption) {
    NSEncryptOptionAES,
    NSEncryptOptionDES,
    NSEncryptOption3DES
};

//非对称加密(公钥加密，私钥解密；反之亦然)
typedef NS_ENUM(NSInteger, NSEncryptRSA) {
    NSEncryptRSAPublicKey,
    NSEncryptRSAPrivateKey //和NSEncryptRSAPublicKey使用
};

@interface NSCrypto : NSObject

#pragma mark - 对称加密(只有一个秘钥)
/**
 *  对称加密
 *
 *  @param data 二进制数据
 *  @param key 秘钥
 *  @param option 选择加密一种类型
 *
 *  @return data
 */
+ (NSData *)encrypt:(NSData *)data key:(NSString *)key option:(NSEncryptOption)option;

/**
 *  对称解密
 *
 *  @param data 二进制数据
 *  @param key 秘钥
 *  @param option 选择加密一种类型
 *
 *  @return data
 */
+ (NSData *)decrypt:(NSData *)data key:(NSString *)key option:(NSEncryptOption)option;


#pragma mark - 非对称加密(公钥和私钥)
/**
 *  非对称加密
 *
 *  @param data 二进制数据
 *  @param key 秘钥
 *  @param option 选择一种加密秘钥
 *
 *  @return data
 */
+ (NSData *)encryptRSA:(NSData *)data key:(NSString *)key option:(NSEncryptRSA)option;

/**
 *  非对称解密
 *
 *  @param data 二进制数据
 *  @param key 秘钥
 *  @param option 选择一种解密秘钥
 *
 *  @return data
 */
+ (NSData *)decryptRSA:(NSData *)data key:(NSString *)key option:(NSEncryptRSA)option;


@end
