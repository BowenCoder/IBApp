//
//  IBCrypto.h
//  IBApplication
//
//  Created by Bowen on 2018/6/26.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

//对称加密
typedef NS_ENUM(NSInteger, IBEncryptOption) {
    IBEncryptOptionAES,
    IBEncryptOptionDES,
    IBEncryptOption3DES,
    IBEncryptOptionRC4,
};

//非对称加密(公钥加密，私钥解密；反之亦然)
typedef NS_ENUM(NSInteger, IBEncryptRSA) {
    IBEncryptRSAPublicKey,
    IBEncryptRSAPrivateKey //和NSEncryptRSAPublicKey使用
};

@interface IBCrypto : NSObject

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
+ (NSData *)encrypt:(NSData *)data key:(NSString *)key option:(IBEncryptOption)option;

/**
 *  对称解密
 *
 *  @param data 二进制数据
 *  @param key 秘钥
 *  @param option 选择加密一种类型
 *
 *  @return data
 */
+ (NSData *)decrypt:(NSData *)data key:(NSString *)key option:(IBEncryptOption)option;


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
+ (NSData *)encryptRSA:(NSData *)data key:(NSString *)key option:(IBEncryptRSA)option;

/**
 *  非对称解密
 *
 *  @param data 二进制数据
 *  @param key 秘钥
 *  @param option 选择一种解密秘钥
 *
 *  @return data
 */
+ (NSData *)decryptRSA:(NSData *)data key:(NSString *)key option:(IBEncryptRSA)option;


@end
