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
 *  数据解码后分发协议
 */
@protocol MBSocketDecoderDispatchProtocol <NSObject>

@required

- (void)didDecode:(MBSocketReceivePacket *)receivePacket;

@end

/**
 *  数据解码协议
 */
@protocol MBSocketDecoderProtocol <NSObject>

@required
/**
 *  解码器
 *  @param receiveData 接收到的原始数据
 *  @param dispatch    数据解码后，分发对象
 */
- (void)decodeReceiveData:(NSData *)receiveData dispatch:(id<MBSocketDecoderDispatchProtocol>)dispatch;

@end


/**
 *  数据编码后分发协议
 */
@protocol MBSocketEncoderDispatchProtocol <NSObject>

@required

- (void)didEncode:(NSData *)encodedData;

@end

/**
 *  数据编码协议
 */
@protocol MBSocketEncoderProtocol <NSObject>

@required
/**
 *  编码器
 *  @param sendPacket 待发送的数据包
 *  @param dispatch   数据编码后，分发对象
 */
- (void)encodeSendPacket:(MBSocketSendPacket *)sendPacket dispatch:(id<MBSocketEncoderDispatchProtocol>)dispatch;

@end

#endif /* MBSocketEncodeProtocol_h */
