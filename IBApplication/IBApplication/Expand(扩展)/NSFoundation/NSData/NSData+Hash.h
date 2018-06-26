//
//  NSData+Hash.h
//  IBApplication
//
//  Created by Bowen on 2018/6/22.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

//Hmac加密
typedef NS_ENUM(NSInteger, IBCHmacAlgorithm) {
    IBCHmacAlgorithmSHA1,
    IBCHmacAlgorithmMD5,
    IBCHmacAlgorithmSHA256,
    IBCHmacAlgorithmSHA384,
    IBCHmacAlgorithmSHA512,
    IBCHmacAlgorithmSHA224
};

//hash加密
typedef NS_ENUM(NSInteger, IBCHashAlgorithm) {
    IBCHashAlgorithmSHA1,
    IBCHashAlgorithmMD5,
    IBCHashAlgorithmSHA256,
    IBCHashAlgorithmSHA384,
    IBCHashAlgorithmSHA512,
    IBCHashAlgorithmSHA224
};

@interface NSData (Hash)

/**
*  @brief           键控哈希算法
*
*  @param key       密钥
*  @param algorithm 算法类型
*
*  @return          结果
*/
- (NSData *)hmac:(NSString *)key algorithm:(IBCHmacAlgorithm)algorithm;

/**
 *  @brief           哈希算法
 *
 *  @param algorithm 算法类型
 *
 *  @return          结果
 */
- (NSData *)hash:(IBCHashAlgorithm)algorithm;

@end
