//
//  NSSocketClient.m
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSSocketClient.h"
#import "NSNetworkStatus.h"

@interface NSSocketClient ()
{
    // 记录重连的次数,默认最大为重连一百次
    NSInteger _connectCount;
    // 重连时间间隔
    NSTimeInterval _connectInterval;
}

/**
 重连定时器
 */
@property (nonatomic, strong) dispatch_source_t reconnectTimer;

@end

@implementation NSSocketClient

- (instancetype)initWithConnectConfig:(NSSocketConfig *)connectConfig {
    if (self = [super initWithConnectConfig:connectConfig]) {
        [self resetConnectData];
    }
    return self;
}

- (void)openConnection {
    
    [super openConnection];
    [self stopReconnectTimer];
}

- (void)closeConnection {
    
    [super closeConnection];
    [self stopReconnectTimer];
}

#pragma mark - NSSocketDelegate

- (void)didConnect:(id<NSSocketDelegate>)delegate toHost:(NSString *)host port:(uint16_t)port {
    
    [self stopReconnectTimer];
    [self resetConnectData];
    [super didConnect:delegate toHost:host port:port];
}


- (void)didDisconnect:(id<NSSocketDelegate>)delegate withError:(NSError *)err {
    
    if ([self isCanReconnectSocket] && !_reconnectTimer) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_connectInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startReconnectTimer:self->_connectInterval];
        });
    }
    [super didDisconnect:delegate withError:err];
}

- (void)resetConnectData {
    // 充值参数
    _connectCount = 0;
    _connectInterval = self.connectConfig.connectInterval;
}

#pragma mark - 重连
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
        [self reconnectTimerFunction];
    });
    dispatch_resume(self.reconnectTimer);
}

- (void)reconnectTimerFunction {
    
    NSLog(@"1.开启重连....");
    if (![self isCanReconnectSocket]) {
        [self stopReconnectTimer];
        return;
    }
    NSLog(@"2.开启重连....");
    _connectCount++;
    if (_connectCount % 10 == 0) {
        _connectInterval += self.connectConfig.connectInterval;
        NSLog(@"3.开启重连....");
        [self startReconnectTimer:_connectInterval];
    }
    NSLog(@"4.开启重连....");
    [self openConnection];
}

- (void)stopReconnectTimer {
    
    if (_reconnectTimer) {
        dispatch_source_cancel(_reconnectTimer);
        _reconnectTimer = NULL;
    }
}

- (BOOL)isCanReconnectSocket {
    
    return (![self isConnected] && self.connectConfig.autoReconnect && [NSNetworkStatus shareNetworkStatus].isReachable && _connectCount < self.connectConfig.connectMaxCount);
}




@end
