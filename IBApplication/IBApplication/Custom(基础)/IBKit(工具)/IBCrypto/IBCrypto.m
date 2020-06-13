//
//  IBCrypto.m
//  IBApplication
//
//  Created by Bowen on 2018/6/26.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBCrypto.h"
#import <CommonCrypto/CommonCryptor.h>
#import "IBEncode.h"

@implementation IBCrypto

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
+ (NSData *)encrypt:(NSData *)data key:(NSString *)key option:(IBEncryptOption)option {
    
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    return [self execute:data key:keyData option:option encrypt:YES];
}

/**
 *  对称解密
 *
 *  @param data 二进制数据
 *  @param key 秘钥
 *  @param option 选择加密一种类型
 *
 *  @return data
 */
+ (NSData *)decrypt:(NSData *)data key:(NSString *)key option:(IBEncryptOption)option {
    
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    return [self execute:data key:keyData option:option encrypt:NO];
}

+ (NSData *)execute:(NSData *)data key:(NSData *)keyData option:(IBEncryptOption)option encrypt:(BOOL)encrypt{
    
    CCAlgorithm algorithm = 0;
    size_t keyLength = 0;
    match(option, &algorithm, &keyLength);
    
    size_t dataMoved = 0;
    size_t bufferSize = data.length + keyLength;
    NSMutableData *decryptedData = [NSMutableData dataWithLength:bufferSize];
    
    CCOperation operation;
    if (encrypt) {
        operation = kCCEncrypt;
    } else {
        operation = kCCDecrypt;
    }
    
    CCCryptorStatus status = CCCrypt(operation,                              // kCCEncrypt or kCCDecrypt
                                     algorithm,
                                     kCCOptionPKCS7Padding|kCCOptionECBMode, // Padding option for CBC Mode
                                     keyData.bytes,
                                     keyLength,
                                     NULL,
                                     data.bytes,
                                     data.length,
                                     decryptedData.mutableBytes,             // encrypted data out
                                     bufferSize,
                                     &dataMoved);                           // total data moved
    
    if (status == kCCSuccess) {
        decryptedData.length = dataMoved;
        return decryptedData;
    }
    
    return nil;
}

void match(IBEncryptOption option,CCAlgorithm *algorithm, size_t *keyLength) {
    
    switch (option) {
        case IBEncryptOptionAES:
            *algorithm = kCCAlgorithmAES;
            *keyLength = kCCKeySizeAES128;
            break;
        case IBEncryptOptionDES:
            *algorithm = kCCAlgorithmDES;
            *keyLength = kCCKeySizeDES;
            break;
        case IBEncryptOption3DES:
            *algorithm = kCCAlgorithm3DES;
            *keyLength = kCCKeySize3DES;
            break;
        case IBEncryptOptionRC4:
            *algorithm = kCCAlgorithmRC4;
            *keyLength = kCCKeySizeMaxRC4;
            break;
        default:
            break;
    }
}

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
+ (NSData *)encryptRSA:(NSData *)data key:(NSString *)key option:(IBEncryptRSA)option {
    
    if(!data || !key) {
        return nil;
    }
    
    SecKeyRef keyRef = [self fetchSecKeyRef:key option:option];
    if(!keyRef) {
        return nil;
    }
    if (option == IBEncryptRSAPublicKey) {//公钥加密
        return [self encrypt:data keyRef:keyRef isSign:NO];
    } else { //私钥加密
        return [self encrypt:data keyRef:keyRef isSign:YES];
    }
}
/**
 *  非对称解密
 *
 *  @param data 二进制数据
 *  @param key 秘钥
 *  @param option 选择一种解密秘钥
 *
 *  @return data
 */
+ (NSData *)decryptRSA:(NSData *)data key:(NSString *)key option:(IBEncryptRSA)option {
    
    if(!data || !key) {
        return nil;
    }
    
    SecKeyRef keyRef = [self fetchSecKeyRef:key option:option];
    if(!keyRef) {
        return nil;
    }
    return [self decrypt:data keyRef:keyRef];
}

+ (SecKeyRef)fetchSecKeyRef:(NSString *)key option:(IBEncryptRSA)option {
    
    NSRange spos;
    NSRange epos;
    if (option == IBEncryptRSAPublicKey) { //区分公钥私钥
        spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
        epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
    } else {
        spos = [key rangeOfString:@"-----BEGIN PRIVATE KEY-----"];
        epos = [key rangeOfString:@"-----END PRIVATE KEY-----"];
    }
    
    if(spos.location != NSNotFound && epos.location != NSNotFound) {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    // This will be base64 encoded, decode it.
    NSData *data = [IBEncode decodeBase64:key];
    //a tag to read/write keychain storage
    NSString *tag;
    if (option == IBEncryptRSAPublicKey) { //区分公钥私钥
        data = [self publicKeyHeader:data];
        tag = @"RSAPublicKey";
    } else {
        data = [self privateKeyHeader:data];
        tag = @"RSAPrivateKey";
    }
    
    if(!data){
        return nil;
    }
    
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [query setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [query setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)query);
    
    // Add persistent version of the key to system keychain
    [query setObject:data forKey:(__bridge id)kSecValueData];
    [query setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)
     kSecAttrKeyClass];
    
    if (option == IBEncryptRSAPublicKey) { //区分公钥私钥
        [query setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
         kSecReturnPersistentRef];
    } else {
        [query setObject:(__bridge id) kSecAttrKeyClassPrivate forKey:(__bridge id)
         kSecAttrKeyClass];
    }
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, &persistKey);
    if (persistKey != nil){
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }
    
    [query removeObjectForKey:(__bridge id)kSecValueData];
    [query removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [query setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [query setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&keyRef);
    if(status != noErr) {
        return nil;
    }
    return keyRef;
}

+ (NSData *)encrypt:(NSData *)data keyRef:(SecKeyRef)keyRef isSign:(BOOL)isSign {
    
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    void *outbuf = malloc(block_size);
    size_t src_block_size = block_size - 11;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx=0; idx<srclen; idx+=src_block_size){
        //NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }
        
        size_t outlen = block_size;
        OSStatus status = noErr;
        
        if (isSign) {
            status = SecKeyRawSign(keyRef,
                                   kSecPaddingPKCS1,
                                   srcbuf + idx,
                                   data_len,
                                   outbuf,
                                   &outlen
                                   );
        } else {
            status = SecKeyEncrypt(keyRef,
                                   kSecPaddingPKCS1,
                                   srcbuf + idx,
                                   data_len,
                                   outbuf,
                                   &outlen
                                   );
        }
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", status);
            ret = nil;
            break;
        }else {
            [ret appendBytes:outbuf length:outlen];
        }
    }
    
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

+ (NSData *)decrypt:(NSData *)data keyRef:(SecKeyRef)keyRef {
    
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    UInt8 *outbuf = malloc(block_size);
    size_t src_block_size = block_size;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx=0; idx<srclen; idx+=src_block_size){
        //NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }
        
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyDecrypt(keyRef,
                               kSecPaddingNone,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen
                               );
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", status);
            ret = nil;
            break;
        } else {
            //the actual decrypted data is in the middle, locate it!
            int idxFirstZero = -1;
            int idxNextZero = (int)outlen;
            for ( int i = 0; i < outlen; i++ ) {
                if ( outbuf[i] == 0 ) {
                    if ( idxFirstZero < 0 ) {
                        idxFirstZero = i;
                    } else {
                        idxNextZero = i;
                        break;
                    }
                }
            }
            
            [ret appendBytes:&outbuf[idxFirstZero+1] length:idxNextZero-idxFirstZero-1];
        }
    }
    
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

+ (NSData *)publicKeyHeader:(NSData *)keyData {
    
    // Skip ASN.1 public key header
    if (keyData == nil) return(nil);
    
    unsigned long len = [keyData length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[keyData bytes];
    unsigned int  idx     = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
    // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

+ (NSData *)privateKeyHeader:(NSData *)d_key{
    
    // Skip ASN.1 private key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx     = 22; //magic byte at offset 22
    
    if (0x04 != c_key[idx++]) return nil;
    
    //calculate length of the key
    unsigned int c_len = c_key[idx++];
    int det = c_len & 0x80;
    if (!det) {
        c_len = c_len & 0x7f;
    } else {
        int byteCount = c_len & 0x7f;
        if (byteCount + idx > len) {
            //rsa length field longer than buffer
            return nil;
        }
        unsigned int accum = 0;
        unsigned char *ptr = &c_key[idx];
        idx += byteCount;
        while (byteCount) {
            accum = (accum << 8) + *ptr;
            ptr++;
            byteCount--;
        }
        c_len = accum;
    }
    
    // Now make a new NSData from this buffer
    return [d_key subdataWithRange:NSMakeRange(idx, c_len)];
}

@end
