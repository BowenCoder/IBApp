//
//  MBSocketPacketBuilder.m
//  IBApplication
//
//  Created by Bowen on 2020/6/12.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketPacketBuilder.h"

@implementation MBSocketPacketBuilder

+ (MBSocketSendPacket *)heartbeatPacket
{
    MBSocketSendPacket *packet = [[MBSocketSendPacket alloc] initWithPacketType:MBSocketMessageHeartbeat body:nil];
    return packet;
}

+ (MBSocketSendPacket *)handshakePacket
{
    MBSocketSendPacket *packet = [[MBSocketSendPacket alloc] initWithPacketType:MBSocketMessageHandshake body:nil];
    return packet;
}

+ (MBSocketSendPacket *)loginPacket:(NSDictionary *)atomDict
{
    MBSocketSendPacket *packet = [[MBSocketSendPacket alloc] initWithPacketType:MBSocketMessageLogin body:atomDict];
    return packet;
}

@end
