//
//  NSSocketPacket.h
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSSocketCMDType.h"
#import "NSSocketByte.h"

@interface NSSocketPacket : NSObject

@property (nonatomic, assign) NSSocketMsgType packetType;
@property (nonatomic, strong) NSSocketByte *socketByte;

@end

@interface NSUploadDataPacket : NSSocketPacket

/**
 在这里对数据包进行了解析
 注意: 每个公司定的数据包格式不同,解析方法也不同

 @param packetType 协议号类型
 @param content 内容
 @return 包
 */
- (instancetype)initWithPacketType:(NSSocketMsgType)packetType content:(NSDictionary *)content;

@end

@interface NSDownloadDataPacket : NSSocketPacket

@property (nonatomic, strong) NSDictionary *packetDict;

- (instancetype)initWithData:(NSData *)data;

@end
