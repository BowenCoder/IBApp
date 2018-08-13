//
//  IBSocketPacketDecode.m
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBSocketPacketDecode.h"

@interface IBSocketPacketDecode ()

/**
 包长度数据的字节个数，默认为2
 */
@property (nonatomic, assign) int countOMMengthByte;
/**
 *  应用协议中允许发送的最大数据块大小，默认为65536
 */
@property (nonatomic, assign) NSUInteger maxFrameSize;

@end

@implementation IBSocketPacketDecode

- (instancetype)init {
    
    if (self = [super init]) {
        _countOMMengthByte = 2;
        _maxFrameSize = 65536;
    }
    return self;
}

/* 处理了粘包和断包的情况 */
- (NSInteger)decodeDownPacket:(NSData *)downPacket output:(id<IBSocketDecoderOutputProtocol>)output {
    
    // 读取数据的下标
    NSUInteger headIndex = 0;
    while (!kIsEmptyData(downPacket) && downPacket.length > _countOMMengthByte + headIndex) {
        // 包长度
        NSInteger dataLength = 0;
        [downPacket getBytes:&dataLength range:NSMakeRange(headIndex, _countOMMengthByte)];
        dataLength = ntohs(dataLength);
        NSAssert(dataLength + _countOMMengthByte < _maxFrameSize, @"DecodeData Length Too Long ...");
        // 数据不是完整的数据包，则break继续读取等待
        if (downPacket.length - headIndex < dataLength + _countOMMengthByte) {
            break;
        }
        NSData *packetData = [downPacket subdataWithRange:NSMakeRange(headIndex + _countOMMengthByte, dataLength)];
        IBDownloadDataPacket *downPacket = [[IBDownloadDataPacket alloc] initWithData:packetData];
        [output didDecode:downPacket];
        headIndex += packetData.length + _countOMMengthByte;
    }
    return headIndex;
}

@end
