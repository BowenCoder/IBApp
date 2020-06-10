//
//  MBSocketEncodeProtocol.h
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#ifndef MBSocketEncodeProtocol_h
#define MBSocketEncodeProtocol_h

#import "MBSocketPacket.h"

/**
 *  数据解码协议
 */
@protocol MBSocketDecoderProtocol <NSObject>

@required

/**
 *  解码头部数据
 */
+ (void)decodeHeaderData:(MBSocketReceivePacket *)packet data:(NSData *)data;

/**
 *  解码扩展的头部数据
 */
+ (void)decodeExtraHeaderData:(MBSocketReceivePacket *)packet data:(NSData *)data;

/**
*  解码数据
*/
+ (void)decodeBodyData:(MBSocketReceivePacket *)packet data:(NSData *)data;

@end

/**
 *  数据编码协议
 */
@protocol MBSocketEncoderProtocol <NSObject>

@required
/**
 *  编码器
 *  @param sendPacket 待发送的数据包
 */
+ (void)encodeSendPacket:(MBSocketSendPacket *)sendPacket;

@end

#endif /* MBSocketEncodeProtocol_h */
