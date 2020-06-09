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

@property (nonatomic, assign) NSInteger uid;

@property (nonatomic, assign) NSInteger bodyLength;
@property (nonatomic, copy) NSDictionary *bodyDict;
@property (nonatomic, copy) NSMutableData *bodyData;

@property (nonatomic, assign) NSInteger extraHeaderLength;
@property (nonatomic, copy) NSDictionary *extraHeaderDict;
@property (nonatomic, copy) NSMutableData *extraHeaderData;

@end


@interface MBSocketSendPacket : MBSocketPacket

@property (nonatomic, assign) NSInteger version;
@property (nonatomic, assign) NSInteger sesssionId;

@property (nonatomic, strong) NSMutableData *sendData;

- (instancetype)initWithPacketType:(MBSocketMessageType)messageType
                              body:(NSDictionary *)body;

+ (void)setSessionId:(NSInteger)sessionId uid:(NSInteger)uid;

- (void)addExtraHeader:(NSDictionary *)header;

@end


@interface MBSocketReceivePacket : MBSocketPacket

@property (nonatomic, assign) MBSocketErrorCode code;
@property (nonatomic, strong) NSMutableDictionary *packetDict;

@end

NS_ASSUME_NONNULL_END
