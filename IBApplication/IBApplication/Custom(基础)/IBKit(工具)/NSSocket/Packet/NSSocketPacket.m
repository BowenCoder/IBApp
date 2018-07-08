//
//  NSSocketPacket.m
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSSocketPacket.h"
#import "IBHelper.h"

#define BYTES_INT   4
#define BYTES_SHORT 2

@implementation NSSocketPacket

@end


@interface NSUploadDataPacket ()

@property (nonatomic, strong) NSMutableData *requestData;

@end

@implementation NSUploadDataPacket

- (instancetype)initWithPacketType:(NSSocketMsgType)packetType content:(NSDictionary *)content {
    
    if (self = [super init]) {
        
        self.packetType = packetType;
        self.socketByte = [[NSSocketByte alloc] init];
        [self.socketByte writeInt32:packetType useHost:YES];
        if (![IBHelper isEmptyDic:content]) {
            NSString *param = [IBHelper JSONString:content];
            [self.socketByte writeInt16:param.length useHost:YES];
            [self.socketByte writeString:param];
        }
    }
    return self;
}

@end

@implementation NSDownloadDataPacket

- (instancetype)initWithData:(NSData *)data {
    
    if (self = [super init]) {
        self.socketByte = [[NSSocketByte alloc] initWithData:data];
        self.packetType = [self.socketByte readInt32:0 useHost:YES];
        if (data.length > BYTES_INT) {
            NSData *temp = [self.socketByte readData:BYTES_INT + BYTES_SHORT length:data.length - BYTES_SHORT - BYTES_INT];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:temp options:kNilOptions error:nil];
            self.packetDict = json;
        }
    }
    return self;
}

@end

