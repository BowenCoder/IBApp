//
//  NSData+Hash.m
//  IBApplication
//
//  Created by Bowen on 2018/6/22.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSData+Hash.h"
#include <CommonCrypto/CommonCrypto.h>

@implementation NSData (Hash)

- (NSData *)hmac:(NSString *)key algorithm:(IBCHmacAlgorithm)algorithm {

    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    CCHmacAlgorithm rule;
    size_t digestLength;
    
    switch (algorithm) {
        case IBCHmacAlgorithmSHA1:
            rule         = kCCHmacAlgSHA1;
            digestLength = CC_SHA1_DIGEST_LENGTH;
            break;
        case IBCHmacAlgorithmMD5:
            rule         = kCCHmacAlgMD5;
            digestLength = CC_MD5_DIGEST_LENGTH;
            break;
        case IBCHmacAlgorithmSHA256:
            rule         = kCCHmacAlgSHA256;
            digestLength = CC_SHA256_DIGEST_LENGTH;
            break;
        case IBCHmacAlgorithmSHA384:
            rule         = kCCHmacAlgSHA384;
            digestLength = CC_SHA384_DIGEST_LENGTH;
            break;
        case IBCHmacAlgorithmSHA512:
            rule         = kCCHmacAlgSHA512;
            digestLength = CC_SHA512_DIGEST_LENGTH;
            break;
        case IBCHmacAlgorithmSHA224:
            rule         = kCCHmacAlgSHA224;
            digestLength = CC_SHA224_DIGEST_LENGTH;
            break;
            
        default:
            break;
    }

    unsigned char result[digestLength];
    CCHmac(rule, [keyData bytes], key.length, self.bytes, self.length, result);
    return [NSData dataWithBytes:result length:digestLength];
}

- (NSData *)hash:(IBCHashAlgorithm)algorithm {
    
    NSData *data;
    switch (algorithm) {
        case IBCHashAlgorithmSHA1: {
            unsigned char bytes[CC_SHA1_DIGEST_LENGTH];
            CC_SHA1(self.bytes, (CC_LONG)self.length, bytes);
            data =[NSData dataWithBytes:bytes length:CC_SHA1_DIGEST_LENGTH];
        }
            break;
        case IBCHashAlgorithmMD5: {
            unsigned char bytes[CC_MD5_DIGEST_LENGTH];
            CC_MD5(self.bytes, (CC_LONG)self.length, bytes);
            data = [NSData dataWithBytes:bytes length:CC_MD5_DIGEST_LENGTH];
        }
            break;
        case IBCHashAlgorithmSHA256: {
            unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
            CC_SHA256(self.bytes, (CC_LONG)self.length, bytes);
            data = [NSData dataWithBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
        }
            break;
        case IBCHashAlgorithmSHA384: {
            unsigned char bytes[CC_SHA384_DIGEST_LENGTH];
            CC_SHA384(self.bytes, (CC_LONG)self.length, bytes);
            data = [NSData dataWithBytes:bytes length:CC_SHA384_DIGEST_LENGTH];
        }
            break;
        case IBCHashAlgorithmSHA512: {
            unsigned char bytes[CC_SHA512_DIGEST_LENGTH];
            CC_SHA512(self.bytes, (CC_LONG)self.length, bytes);
            data = [NSData dataWithBytes:bytes length:CC_SHA512_DIGEST_LENGTH];
        }
            break;
        case IBCHashAlgorithmSHA224: {
            unsigned char bytes[CC_SHA224_DIGEST_LENGTH];
            CC_SHA512(self.bytes, (CC_LONG)self.length, bytes);
            data = [NSData dataWithBytes:bytes length:CC_SHA224_DIGEST_LENGTH];
        }
            break;
        default:
            break;
    }

    return data;
}


@end
