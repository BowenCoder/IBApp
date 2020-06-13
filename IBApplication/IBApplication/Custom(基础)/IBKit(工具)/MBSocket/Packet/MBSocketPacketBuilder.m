//
//  MBSocketPacketBuilder.m
//  IBApplication
//
//  Created by Bowen on 2020/6/12.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketPacketBuilder.h"
#import "MBSocketTools.h"

@implementation MBSocketPacketBuilder

- (MBSocketSendPacket *)heartbeatPacket
{
    MBSocketSendPacket *packet = [[MBSocketSendPacket alloc] initWithPacketType:MBSocketMessageHeartbeat body:nil];
    return packet;
}

- (MBSocketSendPacket *)handshakePacket
{
    NSDictionary *body = @{@"rsaId": @([MBSocketTools rsaPublicKeyId]),
                           @"rc4Key": [MBSocketTools rc4Key]};
    MBSocketSendPacket *packet = [[MBSocketSendPacket alloc] initWithPacketType:MBSocketMessageHandshake body:body];
    return packet;
}

- (MBSocketSendPacket *)loginPacket
{
    MBSocketSendPacket *packet = [[MBSocketSendPacket alloc] initWithPacketType:MBSocketMessageLogin body:self.atomDict];
    return packet;
}

- (MBSocketSendPacket *)commonPacket:(NSDictionary *)body
{
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    [content setObject:self.sessionId forKey:@"sessionId"];
    [content setObject:self.atomDict[@"uid"] forKey:@"uid"];
    [content setObject:body forKey:@"bus"];
    MBSocketSendPacket *packet = [[MBSocketSendPacket alloc] initWithPacketType:MBSocketMessageCommon body:content];
    return packet;
}

@end
