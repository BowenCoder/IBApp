//
//  MBSocketPacketEncode.m
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketPacketEncode.h"
#import "MBSocketByte.h"
#import "IBSerialization.h"
#import "MBSocketTools.h"

@implementation MBSocketPacketEncode

+ (void)encodeSendPacket:(MBSocketSendPacket *)packet
{
    NSData *data = [IBSerialization serializeJsonDataWithDict:packet.bodyDict];
    if (packet.messageType == MBSocketMessageHandshake) {
        packet.bodyData = [MBSocketTools encryptRSA:data];
    } else {
        packet.bodyData = [MBSocketTools encryptRC4:data];
    }
    packet.bodyLength = packet.bodyData.length;
    packet.extraHeaderData = [IBSerialization serializeJsonDataWithDict:packet.extraHeaderDict];
    packet.extraHeaderLength = packet.extraHeaderData.length;
    
    NSMutableData *headerData = [[NSMutableData alloc] initWithLength:packet.headerLength];
    MBSocketByte *headerBytes = [[MBSocketByte alloc] initWithData:headerData];
    
    [headerBytes replaceInt16:packet.mark                index:0  htons:YES];
    [headerBytes replaceInt16:packet.messageType         index:2  htons:YES];
    [headerBytes replaceInt16:(int32_t)packet.appId      index:4  htons:YES];
    [headerBytes replaceInt32:(int32_t)packet.sequence   index:6  htonl:YES];
    [headerBytes replaceInt16:packet.extraHeaderLength   index:10 htons:YES];
    [headerBytes replaceInt16:packet.bodyLength          index:12 htons:YES];
    
    packet.headerData = headerBytes.buffer;
    
}

@end
