//
//  NSData+Encrypt.h
//  IBApplication
//
//  Created by Bowen on 2018/6/22.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

//对称加密
typedef NS_ENUM(NSInteger, IBCEncryptAlgorithm) {
    IBCEncryptAlgorithmAES,
    IBCEncryptAlgorithmDES,
    IBCEncryptAlgorithm3DES
};

//非对称加密(公钥加密，私钥解密；反之亦然)
typedef NS_ENUM(NSInteger, IBCEncryptRSA) {
    IBCEncryptRSAPublicKey,
    IBCEncryptRSAPrivateKey //和IBEncryptRSAPublicKey使用
};

@interface NSData (Encrypt)

#pragma mark - 对称加密(只有一个秘钥)
/**
 *  对称加密
 *
 *  @param key key
 *  @param option 选择加密一种类型
 *
 *  @return data
 */
- (NSData *)encrypt:(NSString *)key option:(IBCEncryptAlgorithm)option;
/**
 *  对称解密
 *
 *  @param key key
 *  @param option 选择加密一种类型
 *
 *  @return data
 */
- (NSData *)decrypt:(NSString *)key option:(IBCEncryptAlgorithm)option;


#pragma mark - 非对称加密(公钥和私钥)
/**
 *  非对称加密
 *
 *  @param key key
 *  @param option 选择一种加密秘钥
 *
 *  @return data
 */
- (NSData *)encryptRSA:(NSString *)key option:(IBCEncryptRSA)option;
/**
 *  非对称解密
 *
 *  @param key key
 *  @param option 选择一种解密秘钥
 *
 *  @return data
 */
- (NSData *)decryptRSA:(NSString *)key option:(IBCEncryptRSA)option;

@end
