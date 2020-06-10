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

@interface MBSocketPacket : NSObject

@property (nonatomic, assign) NSInteger mark;
@property (nonatomic, assign) MBSocketMessageType messageType;
@property (nonatomic, assign) NSInteger sequence;

@property (nonatomic, assign) NSInteger bodyLength;
@property (nonatomic, copy) NSDictionary *bodyDict;
@property (nonatomic, copy) NSData *bodyData;

@property (nonatomic, copy) NSData *headerData;

@property (nonatomic, assign) NSInteger extraHeaderLength;
@property (nonatomic, copy) NSDictionary *extraHeaderDict;
@property (nonatomic, copy) NSData *extraHeaderData;

@end


@interface MBSocketSendPacket : MBSocketPacket

@property (nonatomic, assign) NSInteger sesssionId;
@property (nonatomic, copy) NSData *sendData;

- (instancetype)initWithPacketType:(MBSocketMessageType)messageType
                              body:(NSDictionary *)body;

+ (void)setSessionId:(NSInteger)sessionId;

- (void)addExtraHeader:(NSDictionary *)header;

@end


@interface MBSocketReceivePacket : MBSocketPacket

@property (nonatomic, assign) MBSocketErrorCode code;

@end

NS_ASSUME_NONNULL_END
