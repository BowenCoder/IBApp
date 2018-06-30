//
//  NSSocketClient.h
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSSocketConnection.h"
#import "NSSocketPacket.h"

@class NSSocketClient;

@protocol NSSocketClientDelegate <NSObject>
@required
- (void)clientOpened:(NSSocketClient *)client host:(NSString *)host port:(int)port;
- (void)clientClosed:(NSSocketClient *)client error:(NSError *)error;
- (void)client:(NSSocketClient *)client receiveData:(NSDownloadDataPacket *)packet;

@end

@interface NSSocketClient : NSSocketConnection
/** 心跳包 */
@property (nonatomic, strong) NSUploadDataPacket *heartbeatPacket;
/** 代理 */
@property (nonatomic, weak) id<NSSocketClientDelegate> delegate;

- (void)openConnection;
- (void)closeConnection;

- (void)asyncSendPacket:(NSUploadDataPacket *)packet;

@end
