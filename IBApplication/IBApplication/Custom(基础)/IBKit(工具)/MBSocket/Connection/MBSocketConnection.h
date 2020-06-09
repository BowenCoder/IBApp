//
//  MBSocketConnection.h
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBSocketConnectionModel.h"

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

@end

/// 对GCDAsyncSocket封装
@interface MBSocketConnection : NSObject

@property (nonatomic, strong) MBSocketConnectionModel *connectModel;

- (instancetype)initWithDelegate:(id<MBSocketConnectionDelegate>)delegate;

- (BOOL)isConnected;

- (BOOL)isDisconnected;

- (void)disconnect;

- (void)connectWithModel:(MBSocketConnectionModel *)model;

- (void)sendMessage:(NSData *)message;

@end

NS_ASSUME_NONNULL_END
