//
//  MBSocketClient.h
//  IBApplication
//
//  Created by Bowen on 2020/6/10.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBSocketClientModel.h"

@class MBSocketClient;

NS_ASSUME_NONNULL_BEGIN

@protocol MBSocketClientDelegate <NSObject>

- (void)clientOpened:(MBSocketClient *)client host:(NSString *)host port:(NSInteger)port;

- (void)clientClosed:(MBSocketClient *)client error:(NSError *)error;

- (void)client:(MBSocketClient *)client receiveData:(NSDictionary *)content;

@end

@interface MBSocketClient : NSObject

@property (nonatomic, weak) id<MBSocketClientDelegate> delegate;

- (BOOL)isConnected;

- (BOOL)isDisconnected;

- (void)disconnect;

- (void)connectWithModel:(MBSocketClientModel *)model;

@end

NS_ASSUME_NONNULL_END
