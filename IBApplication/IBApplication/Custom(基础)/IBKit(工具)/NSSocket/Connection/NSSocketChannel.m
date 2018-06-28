//
//  NSSocketChannel.m
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSSocketChannel.h"
#import "NSSocketEncodeProtocol.h"
#import "NSSocketPacketDecode.h"
#import "NSSocketPacketEncode.h"
#import "NSHelper.h"

@interface NSSocketChannel()<NSSocketDecoderOutputProtocol, NSSocketEncoderOutputProtocol>

@property (nonatomic, strong, readonly) NSMutableData *receiveDataBuffer;
/**
 心跳定时器
 */
@property (nonatomic, strong) dispatch_source_t heartbeatTimer;

@property (nonatomic, strong) dispatch_semaphore_t socketLock;

@property (nonatomic, strong) NSSocketPacketDecode *dataDecoder;

@property (nonatomic, strong) NSSocketPacketEncode *dataEncoder;

@end


@implementation NSSocketChannel

- (void)dealloc {
    
    NSLog(@" %@ - dealloc" ,NSStringFromClass([self class]));
}

- (instancetype)initWithConnectConfig:(NSSocketConfig *)connectConfig {
    
    if (self = [super initWithConnectConfig:connectConfig]) {
        
        _receiveDataBuffer = [[NSMutableData alloc] init];
        _socketLock = dispatch_semaphore_create(1);
        _dataDecoder = [[NSSocketPacketDecode alloc] init];
        _dataEncoder = [[NSSocketPacketEncode alloc] init];
    }
    return self;
}

- (void)openConnection {
    
    if ([self isConnected]) {
        return;
    }
    [self closeConnection];
    [self stopHeartbeatTimer];
    [self contect];
}

- (void)closeConnection {
    
    [self disconnect];
    [self stopHeartbeatTimer];
}

- (void)asyncSendPacket:(NSUploadDataPacket *)packet {
    
    if (nil == packet) {
        NSLog(@"Warning: RHSocket asyncSendPacket packet is nil ...");
        return;
    };
    @weakify(self)
    [self dispatchOnSocketQueue:^{
        @strongify(self)
        [self.dataEncoder encodeUpPacket:packet output:self];
    } async:YES];
}

#pragma mark - NSSocketDelegate

- (void)didConnect:(id<NSSocketDelegate>)delegate toHost:(NSString *)host port:(uint16_t)port {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(channelOpened:host:port:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate channelOpened:self host:host port:port];
        });
    }
}


- (void)didDisconnect:(id<NSSocketDelegate>)delegate withError:(NSError *)err {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(channelClosed:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate channelClosed:self error:err];
        });
    }
    [self stopHeartbeatTimer];
}

- (void)didRead:(id<NSSocketDelegate>)delegate withData:(NSData *)data tag:(long)tag {
    
    if ([NSHelper isEmptyData:data]) {
        return;
    }
    dispatch_semaphore_wait(self.socketLock, DISPATCH_TIME_FOREVER);
    [self.receiveDataBuffer appendData:data];
    NSData *responseData = [NSData dataWithData:self.receiveDataBuffer];
    NSInteger decodedLength = [self.dataDecoder decodeDownPacket:responseData output:self];
    if (decodedLength < 0) {
        [self closeConnection];
        NSLog(@"decodedLength < 0 ... decodData Fail");
        return;
    }
    if (decodedLength > 0) {
        NSUInteger remainLength = self.receiveDataBuffer.length - decodedLength;
        NSData *remainData = [_receiveDataBuffer subdataWithRange:NSMakeRange(decodedLength, remainLength)];
        [self.receiveDataBuffer setData:remainData];
    }
    dispatch_semaphore_signal(self.socketLock);
}

#pragma mark - 心跳包

// 发送心跳包
- (void)startHeartbeatTimer {
    
    [self stopHeartbeatTimer];
    self.heartbeatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.heartbeatTimer, dispatch_walltime(NULL, 0), self.connectConfig.heartbeatInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.heartbeatTimer, ^{
        if (![self isConnected]) {
            [self stopHeartbeatTimer];
            return;
        }
        [self asyncSendPacket:self.heartbeatPacket];
    });
    dispatch_resume(self.heartbeatTimer);
}

// 停止心跳
- (void)stopHeartbeatTimer
{
    if (_heartbeatTimer)
    {
        dispatch_cancel(_heartbeatTimer);
        _heartbeatTimer = nil;
    }
}

#pragma mark -NSSocketProtocol

- (void)didDecode:(NSDownloadDataPacket *)decodedPacket {
    
    if (decodedPacket.packetType == NSSocket_Msg_HostHeartbeat) return;
    NSLog(@"收到..packetType CMD...%zd packetDict:%@",decodedPacket.packetType,decodedPacket.packetDict);
    if (decodedPacket.packetType == NSSocket_Msg_HostAuth) {
        //开启心跳包
        [self startHeartbeatTimer];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(channel:received:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate channel:self received:decodedPacket];
        });
    }
}

- (void)didEncode:(NSData *)encodedData timeout:(NSInteger)timeout {
    
    if ([NSHelper isEmptyData:encodedData]) {
        return;
    }
    [self writeData:encodedData timeout:timeout];
}

@end
