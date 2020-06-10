//
//  MBSocketPacketDecode.m
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketPacketDecode.h"
#import "IBSerialization.h"

@implementation MBSocketPacketDecode

+ (void)decodeHeaderData:(MBSocketReceivePacket *)packet
{
    MBSocketByte *headerBytes = [[MBSocketByte alloc] initWithData:packet.headerData];
    packet.mark              = [headerBytes readInt16:0  ntohs:YES];
    packet.messageType       = [headerBytes readInt16:2  ntohs:YES];
    packet.sequence          = [headerBytes readInt32:4  ntohl:YES];
    packet.code              = [headerBytes readInt32:8  ntohl:YES];
    packet.extraHeaderLength = [headerBytes readInt16:12 ntohs:YES];
    packet.bodyLength        = [headerBytes readInt16:14 ntohs:YES];
}

+ (void)decodeExtraHeaderData:(MBSocketReceivePacket *)packet
{
    packet.extraHeaderDict = [IBSerialization unSerializeWithJsonData:packet.extraHeaderData error:nil];
}

+ (void)decodeBodyData:(MBSocketReceivePacket *)packet
{
    packet.bodyDict = [IBSerialization unSerializeWithJsonData:packet.bodyData error:nil];
}

@end
