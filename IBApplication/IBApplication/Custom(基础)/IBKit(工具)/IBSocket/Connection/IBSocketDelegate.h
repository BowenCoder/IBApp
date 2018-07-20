//
//  NSSocketDelagate.h
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBSocketPacket.h"

@protocol IBSocketDelegate <NSObject>

/**
 和socket服务器的连接状态
 */
- (void)contect;
/**
 *  主动断开socket服务器连接
 */
- (void)disconnect;
/**
 *  和socket服务器的连接状态
 */
- (BOOL)isConnected;
/**
 *  和socket服务器连接成功的回调方法
 */
- (void)didConnect:(id<IBSocketDelegate>)delegate toHost:(NSString *)host port:(uint16_t)port;
/**
 *  和socket服务器 连接失败／断开连接 的回调方法
 */
- (void)didDisconnect:(id<IBSocketDelegate>)delegate withError:(NSError *)err;
/**
 *  接收到从socket服务器推送下来的下行数据(原始数据流)回调方法
 */
- (void)didRead:(id<IBSocketDelegate>)delegate withData:(NSData *)data tag:(long)tag;
/**
 *  发送数据方法，写socket的上行数据流。根据GCDAsyncSocket提供的方法，对外提供参数。
 */
- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout;

@end
