//
//  MBSocketConnection.h
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBSocketConnection;

NS_ASSUME_NONNULL_BEGIN

@protocol MBSocketConnectionDelegate <NSObject>

/// 连接成功回调
- (void)socketConnectionrDidConnect:(MBSocketConnection *)connection;

/// 连接失败回调
- (void)socketConnectionDidDisconnect:(MBSocketConnection *)connection error:(NSError *)error;

/// 接收数据回调
- (void)socketConnection:(MBSocketConnection *)connection receiveData:(NSData *)data tag:(long)tag;

/// 发送成功回调
- (void)socketConnection:(MBSocketConnection *)connection didWriteDataWithTag:(long)tag;

/// 发生其他错误
- (void)socketConnection:(MBSocketConnection *)connection fail:(NSError *)error;

@end

/// 对GCDAsyncSocket封装
@interface MBSocketConnection : NSObject

- (instancetype)initWithDelegate:(id<MBSocketConnectionDelegate>)delegate;

- (BOOL)isConnected;

- (BOOL)isDisconnected;

- (void)disconnect;

- (void)connectWithHost:(NSString *)host timeout:(NSTimeInterval)timeout port:(uint16_t)port;

- (void)sendMessage:(NSData *)message timeout:(NSTimeInterval)timeout tag:(long)tag;

- (void)readDataToLength:(NSUInteger)length timeout:(NSTimeInterval)timeout tag:(long)tag;

@end

NS_ASSUME_NONNULL_END
