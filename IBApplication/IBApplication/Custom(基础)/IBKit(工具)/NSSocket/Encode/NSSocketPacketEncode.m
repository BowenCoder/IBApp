//
//  NSSocketPacketEncode.m
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSSocketPacketEncode.h"

@interface NSSocketPacketEncode()

@property (nonatomic, assign) NSInteger timeout;

@end

@implementation NSSocketPacketEncode

- (instancetype)init
{
    if (self = [super init]) {
        _timeout = -1;
    }
    return self;
}

- (void)encodeUpPacket:(NSUploadDataPacket *)upPacket output:(id<NSSocketEncoderOutputProtocol>)output {
    
    if (upPacket.socketByte.buffer.length <= 0) {
        NSLog(@"dataRequest is nil");
        return;
    }
    NSSocketByte *socketByte = [[NSSocketByte alloc] init];
    [socketByte writeInt16:upPacket.socketByte.length useHost:YES];
    [socketByte writeData:upPacket.socketByte.buffer];
    [output didEncode:socketByte.buffer timeout:_timeout];
}

@end
