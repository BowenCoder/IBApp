//
//  MBSocketPacketDecode.m
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketPacketDecode.h"
#import "IBSerialization.h"
#import "MBSocketTools.h"

@implementation MBSocketPacketDecode

+ (void)decodeHeaderData:(MBSocketReceivePacket *)packet data:(NSData *)data
{
    MBSocketByte *headerBytes = [[MBSocketByte alloc] initWithData:data];
    packet.headerData         = data;
    packet.mark               = [headerBytes readInt16:0  ntohs:YES];
    packet.messageType        = [headerBytes readInt16:2  ntohs:YES];
    packet.code               = [headerBytes readInt16:4  ntohs:YES];
    packet.sequence           = [headerBytes readInt32:6  ntohl:YES];
    packet.extraHeaderLength  = [headerBytes readInt16:10 ntohs:YES];
    packet.bodyLength         = [headerBytes readInt16:12 ntohs:YES];
}

+ (void)decodeExtraHeaderData:(MBSocketReceivePacket *)packet data:(NSData *)data
{
    packet.extraHeaderData = data;
    packet.extraHeaderDict = [IBSerialization unSerializeWithJsonData:data error:nil];
}

+ (void)decodeBodyData:(MBSocketReceivePacket *)packet data:(NSData *)data
{
    data = [MBSocketTools decryptRC4:data];
    packet.bodyData = data;
    packet.bodyDict = [IBSerialization unSerializeWithJsonData:data error:nil];
}

@end
