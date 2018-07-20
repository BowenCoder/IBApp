//
//  IBSocketEncodeProtocol.h
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBSocketPacket.h"

/**
 *  数据解码后分发对象协议
 */
@protocol IBSocketDecoderOutputProtocol <NSObject>

@required

- (void)didDecode:(IBDownloadDataPacket *)decodedPacket;

@end

@protocol IBSocketDecoderInputProtocol <NSObject>

@required
/**
 *  解码器
 *  @param downPacket 接收到的原始数据
 *  @param output     数据解码后，分发对象
 */
- (NSInteger)decodeDownPacket:(NSData *)downPacket output:(id<IBSocketDecoderOutputProtocol>)output;

@end


/**
 *  数据编码后分发对象协议
 */
@protocol IBSocketEncoderOutputProtocol <NSObject>

@required

- (void)didEncode:(NSData *)encodedData timeout:(NSInteger)timeout;

@end

@protocol IBSocketEncoderInputProtocol <NSObject>

@required
/**
 *  编码器
 *  @param upPacket 待发送的数据包
 *  @param output 数据编码后，分发对象
 */
- (void)encodeUpPacket:(IBUploadDataPacket *)upPacket output:(id<IBSocketEncoderOutputProtocol>)output;

@end
