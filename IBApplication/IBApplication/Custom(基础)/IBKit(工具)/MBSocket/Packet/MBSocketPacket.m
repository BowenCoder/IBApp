//
//  MBSocketPacket.m
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//


#import "MBSocketPacket.h"

static NSInteger kSessionId = 10000;
static NSInteger kUserId = 0;
static NSInteger kMark = 0x89;

@implementation MBSocketPacket

@end

@implementation MBSocketSendPacket

- (instancetype)initWithPacketType:(MBSocketMessageType)messageType
                              body:(NSDictionary *)body

{
    if (self = [super init]) {
        self.messageType = messageType;
        self.bodyDict = body;
    }
    return self;
}

+ (void)setSessionId:(NSInteger)sessionId uid:(NSInteger)uid
{
    kSessionId = sessionId;
    kUserId = uid;
}

- (void)addExtraHeader:(NSDictionary *)header
{
    self.extraHeaderDict = header;
}

- (NSInteger)mark
{
    return kMark;
}

- (NSInteger)version
{
    return kSocketVersion;
}

- (NSInteger)sesssionId
{
    return kSessionId;
}

- (NSInteger)uid
{
    return kUserId;
}

@end

@implementation MBSocketReceivePacket

@end
