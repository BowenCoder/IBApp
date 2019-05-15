//
//  MBLogEncryptFormatter.m
//  IBApplication
//
//  Created by Bowen on 2019/5/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBLogEncryptFormatter.h"
#import "IBCrypto.h"

@interface MBLogEncryptFormatter ()

@property (nonatomic, copy) NSString *encryptKey;

@end

@implementation MBLogEncryptFormatter

- (instancetype)initWithEncryptKey:(NSString*)key
{
    self = [super init];
    
    if (self) {
        _encryptKey = key;
    }
    
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString* message = [super formatLogMessage:logMessage];
    message = [self _encryptMessage:message];
    return message;
}

- (NSString *)_encryptMessage:(NSString *)message
{
    NSData *originalData  = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [IBCrypto encrypt:originalData key:self.encryptKey option:IBEncryptOptionDES];
    NSString *result      = [encryptedData base64EncodedStringWithOptions:0];
    return result;
}


@end
