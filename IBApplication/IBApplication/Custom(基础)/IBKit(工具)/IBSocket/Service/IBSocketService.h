//
//  IBSocketService.h
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IBSocketPacket.h"

/* 验证连接成功和失败 */
extern NSString * const kIBSocketAuthSuccessNotification;
extern NSString * const kIBSocketErrorConnectedNotification;

@protocol IBRoomSocketProtocol <NSObject>

- (void)roomReceivePacket:(IBDownloadDataPacket *)packet;

@end

@protocol IBChannelSocketProtocol <NSObject>

- (void)socketChannelReceivePacket:(IBDownloadDataPacket *)packet;

@end

@interface IBSocketService : NSObject

/** 我在这里采用不同业务逻辑-对应-不同代理 */

/** room代理 */
@property (nonatomic, weak) id<IBRoomSocketProtocol> roomDelegate;

/** channel代理 */
@property (nonatomic, weak) id<IBChannelSocketProtocol> channelDelegate;

+ (instancetype)sharedService;

- (void)appLogin;

- (void)appLogout;

- (void)sendPacketWithPacketType:(IBSocketMsgType)packetType content:(NSDictionary *)content;

@end
