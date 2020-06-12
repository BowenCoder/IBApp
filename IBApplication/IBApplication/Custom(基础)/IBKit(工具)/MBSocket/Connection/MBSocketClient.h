//
//  MBSocketClient.h
//  IBApplication
//
//  Created by Bowen on 2020/6/10.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBSocketClientModel.h"
#import "MBSocketPacket.h"

@class MBSocketClient;

NS_ASSUME_NONNULL_BEGIN

@protocol MBSocketClientDelegate <NSObject>

- (void)clientOpened:(MBSocketClient *)client host:(NSString *)host port:(NSInteger)port;

- (void)clientClosed:(MBSocketClient *)client error:(NSError *)error;

- (void)client:(MBSocketClient *)client receiveData:(MBSocketPacket *)packet;

@end

@interface MBSocketClient : NSObject

@property (nonatomic, weak) id<MBSocketClientDelegate> delegate;

@property (nonatomic, strong) MBSocketClientModel *clientModel;

- (BOOL)isConnected;

- (BOOL)isDisconnected;

- (void)disconnect;

- (void)connect;

- (void)sendPacket:(MBSocketSendPacket *)packet;

@end

NS_ASSUME_NONNULL_END
