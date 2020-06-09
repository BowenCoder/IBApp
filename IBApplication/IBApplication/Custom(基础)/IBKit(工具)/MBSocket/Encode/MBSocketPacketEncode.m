//
//  MBSocketPacketEncode.m
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketPacketEncode.h"

@implementation MBSocketPacketEncode

- (void)encodeSendPacket:(MBSocketSendPacket *)sendPacket dispatch:(id<MBSocketEncoderDispatchProtocol>)dispatch
{
    NSMutableData *headerData = [[NSMutableData alloc] initWithLength:kSocketMessageHeaderLength];
    void *headerBytes = [headerData mutableBytes];
    
    

}

@end
