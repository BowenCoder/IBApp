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
#import "YYModel.h"

@interface MBSocketManager () <MBSocketClientDelegate>

@property (nonatomic, strong) dispatch_source_t heartbeatTimer;
@property (nonatomic, strong) MBSocketClient *client;
@property (nonatomic, strong) MBSocketCompeletionManager *compeletionManager;
@property (nonatomic, strong) MBSocketPacketBuilder *packetBuilder;
@property (nonatomic, assign) MBSocketConnectStatus connectStatus;
@property (nonatomic, strong) NSMutableArray *clients;

@end

@implementation MBSocketManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clients = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)sharedManager
{
    static MBSocketManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MBSocketManager alloc] init];
    });
    return manager;
}

- (void)disconnect
{
    [self stopHeartbeat];
    [self.client disconnect];
}

- (void)connect
{
    self.connectStatus = MBSocketConnectNone;
    __weak typeof(self) weakSelf = self;
    [self prepareConnections:^(NSArray<MBSocketClientModel *> *ips) {
        for (MBSocketClientModel *model in ips) {
            MBSocketClient *client = [[MBSocketClient alloc] init];
            client.delegate = weakSelf;
            client.clientModel = model;
            [client connect];
            [weakSelf.clients addObject:client];
        }
    }];
}

- (void)reconnect
{
    [self disconnect];
    [self connect];
}

- (void)sendData:(NSDictionary *)data compeletion:(MBSocketRspCallback)compeletion
{
    if (self.connectStatus < MBSocketConnectLogined) {
        MBSocketReceivePacket *packet = [[MBSocketReceivePacket alloc] init];
        packet.code = MBSocketErrorNeedLogin;
        compeletion(packet);
        MBLogE(@"#socket# event:sendData value:socket is not login");
        return;
    }
    MBSocketSendPacket *packet = [self.packetBuilder commonPacket:data];
    [self sendPacket:packet compeletion:compeletion];
}

- (void)sendPacket:(MBSocketSendPacket *)packet compeletion:(MBSocketRspCallback)compeletion
{
    dispatch_async([MBSocketTools socketQueue], ^{
        if ([self.client isConnected]) {
            [self.client sendPacket:packet];
            [self.compeletionManager setCompeletion:compeletion forKey:@(packet.sequence).stringValue];
        } else {
            MBLogE(@"#socket# event:sendPacket value:socket is disconnect");
        }
    });
}

- (void)registerMessageWithTarget:(id)target ev:(NSString *)ev tp:(NSString *)tp compeletion:(MBSocketRspCallback)compeletion
{
    if (!target || !ev || !tp || compeletion) {
        MBLogE(@"#socket# event:register.message value:params is invalid");
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

- (void)prepareConnections:(void(^)(NSArray<MBSocketClientModel *> *ips))compeletion
{
    NSString *fullUrl = [NSString stringWithFormat:@"%@?appid=%ld", self.url, self.appId];
    NSURL *url = [NSURL URLWithString:fullUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 30;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if ([dict[@"code"] integerValue] == MBSocketErrorSuccess) {
            NSArray *ips = [NSArray yy_modelArrayWithClass:MBSocketClientModel.class json:dict[@"data"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (compeletion) {
                    compeletion(ips);
                }
            });
        }
    }];
    [sessionDataTask resume];
}

- (void)handshake
{
    __weak typeof(self) weakSelf = self;
    
    MBSocketSendPacket *packet = [self.packetBuilder handshakePacket];
    [self sendPacket:packet compeletion:^(MBSocketReceivePacket *packet) {
        if (packet.code == MBSocketErrorSuccess) {
            weakSelf.connectStatus = MBSocketConnectHandshaked;
            [MBSocketTools setRC4Key: packet.bodyDict[@"rc4Key"]];
            [weakSelf login];
        } else {
            if (packet.code != MBSocketErrorRSAPubKeyExpired) {
                [weakSelf reconnect];
            }
        }
    }];
}

- (void)login
{
    __weak typeof(self) weakSelf = self;
    
    [self stopHeartbeat];
    
    MBSocketSendPacket *packet = [self.packetBuilder loginPacket];
    [self sendPacket:packet compeletion:^(MBSocketReceivePacket *packet) {
        if (packet.code == MBSocketErrorSuccess) {
            weakSelf.connectStatus = MBSocketConnectLogined;
            weakSelf.packetBuilder.sessionId = packet.bodyDict[@"sessionId"];
            [weakSelf startHeartbeat];
        } else {
            [weakSelf relogin];
        }
    }];
}

- (void)relogin
{
    static NSInteger retryCount = 0;
    if (retryCount >= 3) {
        retryCount = 0;
        [self reconnect];
    } else {
        retryCount++;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self login];
        });
    }
}

#pragma mark - 心跳包

- (void)startHeartbeat
{
    __weak typeof(self) weakSelf = self;
    
    [self stopHeartbeat];
    
    dispatch_queue_t queue = dispatch_queue_create("com.bowen.socket.heartbeat", DISPATCH_QUEUE_SERIAL);
    self.heartbeatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.heartbeatTimer, dispatch_walltime(NULL, 0), self.client.clientModel.heartbeatInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.heartbeatTimer, ^{
        if ([weakSelf.client isDisconnected]) {
            [weakSelf stopHeartbeat];
            return;
        }
        MBSocketSendPacket *packet = [weakSelf.packetBuilder heartbeatPacket];
        [weakSelf.client sendPacket:packet];
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
    NSDictionary *body = packet.bodyDict;
    switch (packet.code) {
        case MBSocketErrorNeedHandshake:
            [self handshake];
            MBLogE(@"#socket# event:handshake value:socket need handshake");
            break;
        case MBSocketErrorNeedLogin:
            [self login];
            MBLogE(@"#socket# event:login value:socket need login");
            break;
        case MBSocketErrorRSAPubKeyExpired:
            [MBSocketTools setRsaPublicKeyId:[body[@"keyId"] integerValue] publicKey:body[@"key"]];
            [self handshake];
            MBLogE(@"#socket# event:expired value:rsa public key is expired");
            break;
        case MBSocketErrorKicked: // 中断连接
            [self disconnect];
            MBLogE(@"#socket# event:kicked value:users are kicked out");
            break;
        default:
            break;
    }
}

#pragma mark - MBSocketClientDelegate

- (void)clientOpened:(MBSocketClient *)client host:(NSString *)host port:(NSInteger)port
{
    self.connectStatus = MBSocketConnectConnected;
    self.client = client;
    [self.clients removeObject:client];
    for (MBSocketClient *client in self.clients) {
        [client disconnect];
    }
    [self.clients removeAllObjects];
    
    [self handshake];
}

- (void)clientClosed:(MBSocketClient *)client error:(NSError *)error
{
    [self reconnect];
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

- (void)setAppId:(NSInteger)appId
{
    _appId = appId;
    [MBSocketSendPacket updateAppId:appId];
}

- (MBSocketCompeletionManager *)compeletionManager {
    if(!_compeletionManager){
        _compeletionManager = [[MBSocketCompeletionManager alloc] init];
        _compeletionManager.messageTimeout = self.client.clientModel.messageTimeout;
    }
    return _compeletionManager;
}

- (MBSocketPacketBuilder *)packetBuilder {
    if(!_packetBuilder){
        _packetBuilder = [[MBSocketPacketBuilder alloc] init];
        _packetBuilder.atomDict = self.atomDict;
    }
    return _packetBuilder;
}

@end
