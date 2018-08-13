//
//  IBSocketClient.m
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBSocketClient.h"
#import "IBSocketEncodeProtocol.h"
#import "IBSocketPacketDecode.h"
#import "IBSocketPacketEncode.h"
#import "IBNetworkStatus.h"

@interface IBSocketClient()<IBSocketDecoderOutputProtocol, IBSocketEncoderOutputProtocol>

/** 接收的数据 */
@property (nonatomic, strong, readonly) NSMutableData *receiveDataBuffer;
/** 心跳定时器 */
@property (nonatomic, strong) dispatch_source_t heartbeatTimer;
/** 重连定时器 */
@property (nonatomic, strong) dispatch_source_t reconnectTimer;
/** 重连时间间隔 */
@property (nonatomic, assign) NSTimeInterval connectInterval;
/** 重连次数,默认最大为100次 */
@property (nonatomic, assign) NSInteger connectCount;
/** 数据解包 */
@property (nonatomic, strong) IBSocketPacketDecode *dataDecoder;
/** 数据打包 */
@property (nonatomic, strong) IBSocketPacketEncode *dataEncoder;
/** 锁 */
@property (nonatomic, strong) dispatch_semaphore_t socketLock;

@end


@implementation IBSocketClient

- (void)dealloc {
    
    NSLog(@" %@ - dealloc" ,NSStringFromClass([self class]));
}

- (instancetype)initWithConnectConfig:(IBSocketConfig *)connectConfig {
    
    if (self = [super initWithConnectConfig:connectConfig]) {
        
        _receiveDataBuffer = [[NSMutableData alloc] init];
        _socketLock = dispatch_semaphore_create(1);
        _dataDecoder = [[IBSocketPacketDecode alloc] init];
        _dataEncoder = [[IBSocketPacketEncode alloc] init];
        
        [self resetConnectData];
    }
    return self;
}

- (void)openConnection {
    
    if ([self isConnected]) {
        return;
    }
    [self closeConnection];
    [self stopHeartbeatTimer];
    [self stopReconnectTimer];
    [self contect];
}

- (void)closeConnection {
    
    [self disconnect];
    [self stopHeartbeatTimer];
    [self stopReconnectTimer];
}

- (void)asyncSendPacket:(IBUploadDataPacket *)packet {
    
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

- (void)didConnect:(id<IBSocketDelegate>)delegate toHost:(NSString *)host port:(uint16_t)port {
    
    [self stopReconnectTimer];
    [self resetConnectData];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clientOpened:host:port:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate clientOpened:self host:host port:port];
        });
    }
}

- (void)didDisconnect:(id<IBSocketDelegate>)delegate withError:(NSError *)err {
    
    //开启重连
    if ([self isCanReconnectSocket] && !_reconnectTimer) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_connectInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startReconnectTimer:self.connectInterval];
        });
    }
    //错误发送出去
    if (self.delegate && [self.delegate respondsToSelector:@selector(clientClosed:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate clientClosed:self error:err];
        });
    }
    //停止心跳定时器
    [self stopHeartbeatTimer];
}

- (void)didRead:(id<IBSocketDelegate>)delegate withData:(NSData *)data tag:(long)tag {
    
    if (kIsEmptyData(data)) {
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

#pragma mark - NSSocketDecoderOutputProtocol

- (void)didDecode:(IBDownloadDataPacket *)decodedPacket {
    
    if (decodedPacket.packetType == IBSocket_Msg_HostHeartbeat) return;
    NSLog(@"收到..packetType CMD...%ld packetDict:%@",decodedPacket.packetType,decodedPacket.packetDict);
    if (decodedPacket.packetType == IBSocket_Msg_HostAuth) {
        //开启心跳包
        [self startHeartbeatTimer];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(client:receiveData:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate client:self receiveData:decodedPacket];
        });
    }
}

#pragma mark - NSSocketEncoderOutputProtocol

- (void)didEncode:(NSData *)encodedData timeout:(NSInteger)timeout {
    
    if (kIsEmptyData(encodedData)) {
        return;
    }
    [self writeData:encodedData timeout:timeout];
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
- (void)stopHeartbeatTimer {
    
    if (_heartbeatTimer) {
        dispatch_cancel(_heartbeatTimer);
        _heartbeatTimer = nil;
    }
}

#pragma mark - 重连定时器

- (void)resetConnectData {
    // 充值参数
    _connectCount = 0;
    _connectInterval = self.connectConfig.connectInterval;
}

/**
 重连定时器
 */
- (void)startReconnectTimer:(NSTimeInterval)interval {
    
    NSLog(@"想要开启重连...");
    [self stopReconnectTimer];
    if (![self isCanReconnectSocket]) return;
    
    NSTimeInterval minInterval = MAX(5, interval);
    self.reconnectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.reconnectTimer, dispatch_walltime(NULL, 0), minInterval * NSEC_PER_SEC, 0);
    @weakify(self)
    dispatch_source_set_event_handler(self.reconnectTimer, ^{
        @strongify(self)
        
        NSLog(@"1.开启重连....");
        self.connectCount++;
        if (self.connectCount % 10 == 0) {
            self.connectInterval += self.connectConfig.connectInterval;
            NSLog(@"2.开启重连....");
            [self startReconnectTimer:self.connectInterval];
        }
        NSLog(@"3.开启重连....");
        [self openConnection];

    });
    dispatch_resume(self.reconnectTimer);
}

- (void)stopReconnectTimer {
    
    if (_reconnectTimer) {
        dispatch_source_cancel(_reconnectTimer);
        _reconnectTimer = nil;
    }
}

- (BOOL)isCanReconnectSocket {
    
    return (![self isConnected] && self.connectConfig.autoReconnect && [IBNetworkStatus shareNetworkStatus].isReachable && _connectCount < self.connectConfig.connectMaxCount);
}


@end
