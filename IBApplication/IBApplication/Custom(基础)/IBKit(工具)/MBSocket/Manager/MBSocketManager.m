//
//  MBSocketManager.m
//  IBApplication
//
//  Created by Bowen on 2020/6/12.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketManager.h"
#import "MBSocketClient.h"
#import "MBSocketTools.h"
#import "MBSocketPacketBuilder.h"
#import "MBSocketCompeletionManager.h"
#import "MBLogger.h"

@interface MBSocketManager ()

@property (nonatomic, strong) dispatch_source_t heartbeatTimer;
@property (nonatomic, strong) MBSocketClient *client;
@property (nonatomic, strong) MBSocketCompeletionManager *compeletionManager;

@end

@implementation MBSocketManager

- (void)disconnect
{
    [self.client disconnect];
    [self stopHeartbeat];
}

- (void)connect
{
    
}

- (void)sendData:(NSDictionary *)data compeletion:(MBSocketRspCallback)compeletion
{
    MBSocketSendPacket *packet = [[MBSocketSendPacket alloc] initWithPacketType:MBSocketMessageCommon body:data];
    [self sendPacket:packet compeletion:compeletion];
}

- (void)sendPacket:(MBSocketSendPacket *)packet compeletion:(MBSocketRspCallback)compeletion
{
    if ([self.client isConnected]) {
        [self.client sendPacket:packet];
        [self.compeletionManager setCompeletion:compeletion forKey:@(packet.sequence).stringValue];
    } else {
        MBLogI(@"#socket# event:sendData value:socket is disconnect");
    }
}

- (void)registerMessageWithTarget:(id)target ev:(NSString *)ev tp:(NSString *)tp compeletion:(MBSocketRspCallback)compeletion
{
    if (!target || !ev || !tp || compeletion) {
        MBLogI(@"#socket# event:register.message value:params is invalid");
        return;
    }
    NSString *key = [NSString stringWithFormat:@"%@%@", ev, tp];
    [self.compeletionManager registerMessageCompeletion:compeletion key:key target:target];
}

- (void)removeRegisterMessage:(NSString *)ev tp:(NSString *)tp
{
    NSString *key = [NSString stringWithFormat:@"%@%@", ev, tp];
    [self.compeletionManager removeCompeletionForKey:key];
}

- (void)prepareConnecttions
{
    
}

- (void)handshake
{
    __weak typeof(self) weakSelf = self;

    MBSocketSendPacket *packet = [MBSocketPacketBuilder handshakePacket];
    [self sendPacket:packet compeletion:^(MBSocketReceivePacket *packet) {
        if (packet.code == MBSocketErrorSuccess) {
            [weakSelf login];
        } else {
            [weakSelf connect];
        }
    }];
}

- (void)login
{
    MBSocketSendPacket *packet = [MBSocketPacketBuilder loginPacket:self.atomDict];
    [self sendPacket:packet compeletion:^(MBSocketReceivePacket *packet) {
        
    }];
}

#pragma mark - 心跳包

- (void)startHeartbeat
{
    [self stopHeartbeat];
    
    dispatch_queue_t queue = dispatch_queue_create("com.bowen.socket.heartbeat", DISPATCH_QUEUE_SERIAL);
    self.heartbeatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.heartbeatTimer, dispatch_walltime(NULL, 0), self.client.clientModel.heartbeatInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.heartbeatTimer, ^{
        if ([self.client isDisconnected]) {
            [self stopHeartbeat];
            return;
        }
        MBSocketSendPacket *packet = [MBSocketPacketBuilder heartbeatPacket];
        [self.client sendPacket:packet];
    });
    dispatch_resume(self.heartbeatTimer);
}

- (void)stopHeartbeat
{
    if (self.heartbeatTimer) {
        dispatch_cancel(self.heartbeatTimer);
        self.heartbeatTimer = nil;
    }
}

- (void)didFailWithPacket:(MBSocketReceivePacket *)packet
{
    switch (packet.code) {
        case MBSocketErrorNeedHandshake:
            [self handshake];
            break;
        case MBSocketErrorNeedLogin:
            [self login];
            break;
        case MBSocketErrorRC4KeyExpired:
            [self handshake];
            break;
        case MBSocketErrorRSAPubKeyExpired:
            [self handshake];
            break;
        case MBSocketErrorKicked: // 中断连接
            [self disconnect];
            break;
        default:
            break;
    }
}

#pragma mark - MBSocketClientDelegate

- (void)clientOpened:(MBSocketClient *)client host:(NSString *)host port:(NSInteger)port
{
    [self handshake];
}

- (void)clientClosed:(MBSocketClient *)client error:(NSError *)error
{
    [self connect];
}

- (void)client:(MBSocketClient *)client receiveData:(MBSocketReceivePacket *)packet
{
    if (self.client != client) {
        return;
    }
    
    if (packet.code != MBSocketErrorSuccess) {
        [self didFailWithPacket:packet];
        return;
    }
    
    if (packet.messageType == MBSocketMessageService) {
        NSString *ev = [packet.bodyDict valueForKeyPath:@"b.ev"];
        NSString *tp = [packet.bodyDict valueForKeyPath:@"m.tp"];
        NSString *key = [NSString stringWithFormat:@"%@%@", ev, tp];
        NSArray *compeletions = [self.compeletionManager registerMessageCompeletionsForKey:key];
        for (MBSocketRspCallback callback in compeletions) {
            if (callback) {
                callback(packet);
            }
        }
    } else {
        NSString *key = @(packet.sequence).stringValue;
        MBSocketRspCallback callback = [self.compeletionManager compeletionForKey:key];
        [self.compeletionManager removeCompeletionForKey:key];
        if (callback) {
            callback(packet);
        }
    }
}

#pragma mark - getter, setter

- (MBSocketCompeletionManager *)compeletionManager {
    if(!_compeletionManager){
        _compeletionManager = [[MBSocketCompeletionManager alloc] init];
        _compeletionManager.messageTimeout = self.client.clientModel.messageTimeout;
    }
    return _compeletionManager;
}

@end
