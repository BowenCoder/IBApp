//
//  MBSocketTools.h
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBSocketTools : NSObject

+ (dispatch_queue_t)socketQueue;

+ (void)setRsaPublicKeyId:(NSInteger)keyId publicKey:(NSString *)key;

+ (void)setRC4Key:(NSString *)key;

+ (NSData *)encryptRC4:(NSData *)data;

+ (NSData *)decryptRC4:(NSData *)data;

+ (NSData *)encryptRSA:(NSData *)data;

+ (NSInteger)rsaPublicKeyId;

+ (NSString *)rsaPublicKey;

+ (NSString *)rc4Key;


@end

NS_ASSUME_NONNULL_END
