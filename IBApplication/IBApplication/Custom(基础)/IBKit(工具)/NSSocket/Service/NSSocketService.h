//
//  NSSocketService.h
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSSocketPacket.h"

/* 验证连接成功和失败 */
extern NSString * const kNSSocketAuthSuccessNotification;
extern NSString * const kNSSocketErrorConnectedNotification;

@protocol NSRoomSocketProtocol <NSObject>

- (void)roomReceivePacket:(NSDownloadDataPacket *)packet;

@end

@protocol NSChannelSocketProtocol <NSObject>

- (void)socketChannelReceivePacket:(NSDownloadDataPacket *)packet;

@end

@interface NSSocketService : NSObject

/** 我在这里采用不同业务逻辑-对应-不同代理 */

/** room代理 */
@property (nonatomic, weak) id<NSRoomSocketProtocol> roomDelegate;

/** channel代理 */
@property (nonatomic, weak) id<NSChannelSocketProtocol> channelDelegate;

+ (instancetype)sharedService;

- (void)appLogin;

- (void)appLogout;

- (void)sendPacketWithPacketType:(NSSocketMsgType)packetType content:(NSDictionary *)content;

@end
