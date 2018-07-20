//
//  IBSocketClient.h
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBSocketConnection.h"
#import "IBSocketPacket.h"

@class IBSocketClient;

@protocol IBSocketClientDelegate <NSObject>
@required
- (void)clientOpened:(IBSocketClient *)client host:(NSString *)host port:(int)port;
- (void)clientClosed:(IBSocketClient *)client error:(NSError *)error;
- (void)client:(IBSocketClient *)client receiveData:(IBDownloadDataPacket *)packet;

@end

@interface IBSocketClient : IBSocketConnection
/** 心跳包 */
@property (nonatomic, strong) IBUploadDataPacket *heartbeatPacket;
/** 代理 */
@property (nonatomic, weak) id<IBSocketClientDelegate> delegate;

- (void)openConnection;
- (void)closeConnection;

- (void)asyncSendPacket:(IBUploadDataPacket *)packet;

@end
