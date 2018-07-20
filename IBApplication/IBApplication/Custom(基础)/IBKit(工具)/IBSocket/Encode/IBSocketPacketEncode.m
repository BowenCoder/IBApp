//
//  IBSocketPacketEncode.m
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBSocketPacketEncode.h"

@interface IBSocketPacketEncode()

@property (nonatomic, assign) NSInteger timeout;

@end

@implementation IBSocketPacketEncode

- (instancetype)init {
    
    if (self = [super init]) {
        _timeout = -1;
    }
    return self;
}

- (void)encodeUpPacket:(IBUploadDataPacket *)upPacket output:(id<IBSocketEncoderOutputProtocol>)output {
    
    if (upPacket.socketByte.buffer.length <= 0) {
        NSLog(@"dataRequest is nil");
        return;
    }
    IBSocketByte *socketByte = [[IBSocketByte alloc] init];
    [socketByte writeInt16:upPacket.socketByte.length useHost:YES];
    [socketByte writeData:upPacket.socketByte.buffer];
    [output didEncode:socketByte.buffer timeout:_timeout];
}

@end
