//
//  NSSocketService.m
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSSocketService.h"
#import "NSSocketClient.h"
#import "NSNetworkStatus.h"

NSString * const kNSSocketAuthSuccessNotification = @"kNSSocketAuthSuccessNotification";
NSString * const kNSSocketErrorConnectedNotification = @"kNSSocketErrorConnectedNotification";

static NSSocketService *service = nil;

@interface NSSocketService ()<NSSocketChannelDelegate> {
    BOOL _hostRequesting;
}

@property (nonatomic, strong) NSSocketClient *socketClient;
@property (nonatomic, strong) NSSocketConfig *connectConfig;

@end

@implementation NSSocketService

+ (instancetype)sharedSocketService {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[NSSocketService alloc] init];
    });
    return service;
}

- (void)appLogout {
    
    [self removeNetworkingStatusNotification];
    [self removeAppStatusNotification];
    _connectConfig = nil;
    _hostRequesting = NO;
    [self closeConnection];
}

- (void)appLogin {
    
    [self startConnectSocket];
    [self addAppStatusNotification];
    [self addNetworkingStatusNotification];
}

- (void)closeConnection {
    
    if (_socketClient) {
        [_socketClient closeConnection];
        _socketClient = nil;
    }
}

/**
 启动连接Socket的入口
 */
- (void)startConnectSocket {
    
    if (self.connectConfig) {
        //如果获取到了端口参数
        NSLog(@"开始连接socket...");
        if (!self.socketClient) {
            self.socketClient = [[NSSocketClient alloc] initWithConnectConfig:self.connectConfig];
            self.socketClient.heartbeatPacket = [[NSUploadDataPacket alloc] initWithPacketType:NSSocket_Msg_Heartbeat content:nil];
            self.socketClient.delegate = self;
        }
        [self.socketClient openConnection];
    } else {
        //从服务器请求端口...
        if (!_hostRequesting) {
            NSLog(@"请求socket host...");
            [self requestSocketHostAddress];
        }
    }
}

// 请求获取socket服务器地址
- (void)requestSocketHostAddress {
    
    //这里根据不同的需求产生了不同的业务逻辑代码
    //我们的逻辑是从服务器请求下host和port
    /*
     if(用户已经登录)
     {
     _hostRequesting = YES;
     网络请求成功的回调{
     
     self.connectParam = [[FGSocketConnectParam alloc] init];
     self.connectParam.host = host;
     self.connectParam.port = port;
     [self startConnectSocket];
     
     } 失败{
     [self reconnectSocket];
     }
     }
     */
}

- (void)reconnectSocket {
    
    //如果失败了,5秒后再请求一次
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_hostRequesting = NO;
        [self startConnectSocket];
    });
}

#pragma mark -FGSocketChannelDelegate

- (void)channelOpened:(NSSocketChannel *)channel host:(NSString *)host port:(int)port {
    /* 连接成功的逻辑 */
}

- (void)channelClosed:(NSSocketChannel *)channel error:(NSError *)error {
    /* 连接失败的逻辑 */
}


- (void)channel:(NSSocketChannel *)channel received:(NSDownloadDataPacket *)packet {
    /* 在这里,根据协议号处理具体的业务逻辑... */
}

#pragma mark - Notification

/* 网络状态改变的处理... */
- (void)addNetworkingStatusNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveReachabilityChangedNotification:) name:kNSReachabilityChangedNotification object:NULL];
}

- (void)removeNetworkingStatusNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNSReachabilityChangedNotification object:NULL];
}

- (void)onReceiveReachabilityChangedNotification:(NSNotification *)notification {
    
    if ([NSNetworkStatus shareNetworkStatus].isReachable){
        [self startConnectSocket];
    }
}

/* App前后台切换的处理... */
- (void)addAppStatusNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidChangeStatus:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidChangeStatus:) name:UIApplicationWillEnterForegroundNotification  object:nil];
}

- (void)removeAppStatusNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)handleApplicationDidChangeStatus:(NSNotification *)notification {
    
    /* 前后台切换的要告诉服务器 */
}


#pragma mark - Packet

/**
 发送数据的统一入口...
 */
- (void)sendPacketWithPacketType:(NSSocketMsgType)packetType content:(NSDictionary *)content {
    
    NSLog(@"发送数据包类型:%lu 内容:%@",(unsigned long)packetType,content);
    NSUploadDataPacket *authPacket = [[NSUploadDataPacket alloc] initWithPacketType:packetType content:content];
    [self.socketClient asyncSendPacket:authPacket];
}


- (void)sendAtuh {
    
    /*
     NSDictionary *content = @{
     组装数据
     };
     [self sendPacketWithPacketType:FGSocket_Msg_Auth content:content];
     */
}

@end
