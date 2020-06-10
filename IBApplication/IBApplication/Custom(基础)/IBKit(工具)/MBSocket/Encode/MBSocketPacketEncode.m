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

@implementation MBSocketPacketEncode

+ (void)encodeSendPacket:(MBSocketSendPacket *)packet
{
    packet.bodyData = [IBSerialization serializeJsonDataWithDict:packet.bodyDict];
    packet.bodyLength = packet.bodyData.length;
    packet.extraHeaderData = [IBSerialization serializeJsonDataWithDict:packet.extraHeaderDict];
    packet.extraHeaderLength = packet.extraHeaderData.length;
    
    NSMutableData *headerData = [[NSMutableData alloc] initWithLength:packet.headerLength];
    MBSocketByte *headerBytes = [[MBSocketByte alloc] initWithData:headerData];
    
    [headerBytes replaceInt16:packet.mark                index:0  htons:YES];
    [headerBytes replaceInt16:packet.messageType         index:2  htons:YES];
    [headerBytes replaceInt32:(int32_t)packet.sequence   index:4  htonl:YES];
    [headerBytes replaceInt32:(int32_t)packet.sesssionId index:8  htonl:YES];
    [headerBytes replaceInt16:packet.extraHeaderLength   index:12 htons:YES];
    [headerBytes replaceInt16:packet.bodyLength          index:14 htons:YES];
    
    NSMutableData *sendData = [NSMutableData data];
    [sendData appendData:headerBytes.buffer];
    [sendData appendData:packet.extraHeaderData];
    [sendData appendData:packet.bodyData];
    
    packet.headerData = headerBytes.buffer;
    packet.sendData = sendData;
}

@end
