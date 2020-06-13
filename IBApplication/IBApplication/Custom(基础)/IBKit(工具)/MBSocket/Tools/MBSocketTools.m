//
//  MBSocketTools.m
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketTools.h"
#import "IBCrypto.h"

static NSInteger kRSAPublicKeyId = 1;  // 公钥的序号
static NSString *kRSAPublicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDhSzPPnFn41iaz+t4tI4kbaXNuNFOsI8hFeCYtlwPFKRbETHbBS10bMvUbOWLFtRgZV3L924GQ9orbomEmJ1nWyaSO8iBbZAyiWUP5PJJh/b9kHj1MMwG712bGfYYPdjkRprNpzU9w4UBzUMKKUoHU4c/Gbb4XeBK9LNTPWQL4YwIDAQAB"; // 公钥
static NSString *kRC4Key = @"rc4123456789"; // RC4的秘钥

@implementation MBSocketTools

+ (dispatch_queue_t)socketQueue
{
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.bowen.persistent.socket", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

+ (void)setRsaPublicKeyId:(NSInteger)keyId publicKey:(NSString *)key
{
    kRSAPublicKeyId = keyId;
    kRSAPublicKey = key;
}

+ (void)setRC4Key:(NSString *)key
{
    kRC4Key = key;
}

+ (NSInteger)rsaPublicKeyId
{
    return kRSAPublicKeyId;
}

+ (NSString *)rsaPublicKey
{
    return [self transformKey:kRSAPublicKey encryption:YES];
}

+ (NSString *)rc4Key
{
    return kRC4Key;
}

+ (NSData *)encryptRC4:(NSData *)data
{
    return [IBCrypto encrypt:data key:kRC4Key option:IBEncryptOptionRC4];
}

+ (NSData *)decryptRC4:(NSData *)data
{
    return [IBCrypto decrypt:data key:kRC4Key option:IBEncryptOptionRC4];
}

+ (NSData *)encryptRSA:(NSData *)data
{
    return [IBCrypto encryptRSA:data key:kRSAPublicKey option:IBEncryptRSAPublicKey];
}

+ (NSString*)transformKey:(NSString*)key encryption:(BOOL)isEncryption
{
    if (key.length == 0) {
        return nil;
    }
    
    BOOL increment = NO;
    if (isEncryption) {
        increment = YES;
    }
    
    char *output = malloc(key.length + 1);
    const char *origin =[key UTF8String];
    for (NSInteger i=0; i < key.length; i++) {
        output[i] = [self transformChar:origin[i] increment:increment];
    }
    
    output[key.length] = 0;
    
    NSString* ret = [[NSString alloc] initWithUTF8String:output];
    
    free(output);
    return ret;
}

+ (char)transformChar:(char)inChar increment:(BOOL)increment
{
    NSInteger inc = 0;
    if (increment) {
        inc = 10;
    } else {
        inc = -10;
    }
    
    if (inChar >= 'a' && inChar <= 'z') {
        return 'a' + (inChar - 'a' + inc + 26) % 26;
    }
    
    if (inChar >= 'A' && inChar <= 'Z') {
        return 'A' + (inChar - 'A' + inc + 26) % 26;
    }
    
    return inChar;
}


@end
