//
//  MBSocketPacketBuilder.h
//  IBApplication
//
//  Created by Bowen on 2020/6/12.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBSocketPacket.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBSocketPacketBuilder : NSObject

@property (nonatomic, copy) NSDictionary *atomDict;
@property (nonatomic, copy) NSString *sessionId;

- (MBSocketSendPacket *)heartbeatPacket;

- (MBSocketSendPacket *)handshakePacket;

- (MBSocketSendPacket *)loginPacket;

- (MBSocketSendPacket *)commonPacket:(NSDictionary *)body;

@end

NS_ASSUME_NONNULL_END
