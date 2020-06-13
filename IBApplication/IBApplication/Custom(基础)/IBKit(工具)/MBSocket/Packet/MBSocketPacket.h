//
//  MBSocketPacket.h
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBSocketCMDType.h"
#import "MBSocketByte.h"

NS_ASSUME_NONNULL_BEGIN

/*
 One Packet:
 +-----------------------+
 | header                |
 |  ...                  |<-- kSocketMessageHeaderLength
 |  extra header length  |
 |  body length          |
 +-----------------------+ - - - - - - - - - - - -
 | extra header          | <-- header length      | <-- may not exist
 +-----------------------+ - - - - - - - - - - - -
 | body                  | <-- body length
 +-----------------------+
 */
@interface MBSocketPacket : NSObject

@property (nonatomic, assign) NSInteger mark;
@property (nonatomic, assign) MBSocketMessageType messageType;
@property (nonatomic, assign) NSInteger sequence;

@property (nonatomic, copy) NSData *headerData;
@property (nonatomic, assign) NSInteger headerLength;

@property (nonatomic, copy) NSData *extraHeaderData;
@property (nonatomic, assign) NSInteger extraHeaderLength;
@property (nonatomic, copy) NSDictionary *extraHeaderDict;

@property (nonatomic, copy) NSData *bodyData;
@property (nonatomic, assign) NSInteger bodyLength;
@property (nonatomic, copy) NSDictionary *bodyDict;

@end


@interface MBSocketSendPacket : MBSocketPacket

@property (nonatomic, assign) NSInteger appId; // App的标识

- (instancetype)initWithPacketType:(MBSocketMessageType)messageType
                              body:(nullable NSDictionary *)body;

+ (void)updateAppId:(NSInteger)appId;

+ (void)updateSessionId:(NSString *)sessionId;

- (void)addExtraHeader:(NSDictionary *)header;

@end


@interface MBSocketReceivePacket : MBSocketPacket

@property (nonatomic, assign) MBSocketErrorCode code;

@end

NS_ASSUME_NONNULL_END
