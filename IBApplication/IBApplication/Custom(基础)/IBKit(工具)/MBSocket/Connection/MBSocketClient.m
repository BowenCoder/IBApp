//
//  MBSocketClient.m
//  IBApplication
//
//  Created by Bowen on 2020/6/10.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketClient.h"
#import "MBSocketConnection.h"
#import "MBSocketPacketDecode.h"
#import "MBSocketPacketEncode.h"
#import "MBSocketClientModel.h"
#import "IBNetworkStatus.h"
#import "MBSocketTools.h"
#import "MBLogger.h"

@interface MBSocketClient () <MBSocketConnectionDelegate>

@property (nonatomic, strong) MBSocketConnection *connection;
@property (nonatomic, strong) MBSocketReceivePacket *receivePacket;

@end

@implementation MBSocketClient

- (void)dealloc
{
    [self disconnect];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self registerNotification];
    }
    return self;
}

- (BOOL)isConnected
{
    return [self.connection isConnected];
}

- (BOOL)isDisconnected
{
    return [self.connection isDisconnected];
}

- (void)disconnect
{
    if ([self isDisconnected]) {
        return;
    }
    [self.connection disconnect];
    
    MBLogI(@"#socket# event:disconnect");
}

- (void)connect
{
    if (!self.clientModel) {
        MBLogE(@"#socket# event:connect errror:params is invalid");
        return;
    }
    [self.connection connectWithHost:self.clientModel.host timeout:15 port:self.clientModel.port];
    NSString *key = [NSString stringWithFormat:@"%@:%ld", self.clientModel.host, (long)self.clientModel.port];
    MBLogI(@"#socket# event:connect value: %@", key);
}

- (void)reconnect
{
    MBLogI(@"#socket# event:reconnect");
    [self disconnect];
    [self connect];
}

- (void)sendPacket:(MBSocketSendPacket *)packet
{
    [MBSocketPacketEncode encodeSendPacket:packet];
    NSMutableData *data = [NSMutableData data];
    [data appendData:packet.headerData];
    [data appendData:packet.extraHeaderData];
    [data appendData:packet.bodyData];
    if (self.isConnected) {
        [self.connection sendMessage:data timeout:self.clientModel.messageTimeout tag:kSocketMessageWriteTag];
    } else {
        MBLogE(@"#socket# event:send error:socket is disconnected");
    }
}

#pragma mark - MBSocketConnectionDelegate

/// 发生其他错误
- (void)socketConnection:(MBSocketConnection *)connection fail:(NSError *)error
{
    MBLogE(@"#socket# event:delegate.fail error:%@", error);
}

/// 连接成功回调
- (void)socketConnectionrDidConnect:(MBSocketConnection *)connection
{
    MBLogI(@"#socket# event:delegate.connect value:success");
    
    [self readDataToLength:kSocketMessageHeaderLength tag:kSocketMessageHeaderTag];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(clientOpened:host:port:)]) {
            [self.delegate clientOpened:self host:self.clientModel.host port:self.clientModel.port];
        }
    });
}

/// 连接失败回调
- (void)socketConnectionDidDisconnect:(MBSocketConnection *)connection error:(NSError *)error
{
    MBLogE(@"#socket# event:delegate.disconnect error:%@", error);
    
    if (![IBNetworkStatus shareInstance].reachable) {
        return;
    }

    static NSInteger retryCount = 0;
    
    if (retryCount < self.clientModel.retryConnectMaxCount) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.clientModel.retryConnectInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reconnect];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            retryCount = 0;
            if (self.delegate && [self.delegate respondsToSelector:@selector(clientClosed:error:)]) {
                [self.delegate clientClosed:self error:error];
            }
        });
    }
    
    retryCount++;
}

/// 接收数据回调
- (void)socketConnection:(MBSocketConnection *)connection receiveData:(NSData *)data tag:(long)tag
{
    [self receviceData:data tag:tag];
}

/// 发送成功回调
- (void)socketConnection:(MBSocketConnection *)connection didWriteDataWithTag:(long)tag
{
    
}

#pragma mark - 内部

- (void)readDataToLength:(NSUInteger)length tag:(long)tag
{
    [self.connection readDataToLength:length timeout:-1 tag:tag];
}

- (void)receviceData:(NSData *)data tag:(long)tag
{
    if (!self.connection) {
        return;
    }
    switch (tag) {
        case kSocketMessageHeaderTag:
        {
            self.receivePacket = [[MBSocketReceivePacket alloc] init];
            [MBSocketPacketDecode decodeHeaderData:self.receivePacket data:data];
            if (self.receivePacket.extraHeaderLength > 0) {
                [self readDataToLength:self.receivePacket.extraHeaderLength tag:kSocketMessageExtraHeaderTag];
            } else if (self.receivePacket.bodyLength > 0) {
                [self readDataToLength:self.receivePacket.bodyLength tag:kSocketMessageBodyTag];
            } else {
                [self readDataToLength:kSocketMessageHeaderLength tag:kSocketMessageHeaderTag];
            }
        }
            break;
        case kSocketMessageExtraHeaderTag:
        {
            [MBSocketPacketDecode decodeExtraHeaderData:self.receivePacket data:data];
            if (self.receivePacket.bodyLength > 0) {
                [self readDataToLength:self.receivePacket.bodyLength tag:kSocketMessageBodyTag];
            } else {
                [self readDataToLength:kSocketMessageHeaderLength tag:kSocketMessageHeaderTag];
            }
        }
            break;
        case kSocketMessageBodyTag:
        {
            [MBSocketPacketDecode decodeBodyData:self.receivePacket data:data];
            [self dispatchData];
            [self readDataToLength:kSocketMessageHeaderLength tag:kSocketMessageHeaderTag];
        }
            break;
            
        default:
            break;
    }
}

- (void)dispatchData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(client:receiveData:)]) {
            [self.delegate client:self receiveData:self.receivePacket];
        }
    });
}

#pragma mark - notification

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatusChange:)
                                                 name:kIBReachabilityChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)networkStatusChange:(NSNotification *)notification
{
    if ([self isDisconnected] && [notification.object integerValue] > 0) {
        MBLogI(@"#socket# event:network.retry");
        [self reconnect];
    }
}

- (void)didEnterBackground
{
    MBLogI(@"#socket# event:background");
    [self disconnect];
}

- (void)willEnterForeground
{
    MBLogI(@"#socket# event:foreground");
    [self reconnect];
}

#pragma mark - getter

- (MBSocketConnection *)connection {
    if(!_connection){
        _connection = [[MBSocketConnection alloc] initWithDelegate:self];
    }
    return _connection;
}

@end
