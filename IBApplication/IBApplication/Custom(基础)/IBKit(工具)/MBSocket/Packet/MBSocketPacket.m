//
//  MBSocketPacket.m
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//


#import "MBSocketPacket.h"

static NSInteger kAppId = 10000;
static NSInteger kMark = 0x01;
static NSInteger seq = 0;

@implementation MBSocketPacket

- (NSInteger)headerLength
{
    return kSocketMessageHeaderLength;
}

@end

@implementation MBSocketSendPacket

- (instancetype)initWithPacketType:(MBSocketMessageType)messageType
                              body:(NSDictionary *)body

{
    if (self = [super init]) {
        self.messageType = messageType;
        self.bodyDict = body;
        self.mark = kMark;
        self.sequence = [self generateSequence];
    }
    return self;
}

+ (void)updateAppId:(NSInteger)appId;
{
    kAppId = appId;
}

- (void)addExtraHeader:(NSDictionary *)header
{
    self.extraHeaderDict = header;
}

- (NSInteger)appId
{
    return kAppId;
}

- (NSInteger)generateSequence
{
    return ++seq;
}

@end

@implementation MBSocketReceivePacket

@end
