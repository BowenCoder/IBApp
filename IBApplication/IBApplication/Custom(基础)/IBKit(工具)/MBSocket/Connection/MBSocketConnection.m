//
//  MBSocketConnection.m
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketConnection.h"
#import "GCDAsyncSocket.h"
#import "MBSocketTools.h"
#import "MBSocketCMDType.h"
#import "MBSocketEncodeProtocol.h"

@interface MBSocketConnection () <GCDAsyncSocketDelegate>

@property (nonatomic, weak) id<MBSocketConnectionDelegate> delegate;
@property (nonatomic, strong) GCDAsyncSocket *gcdSocket;

@end

@implementation MBSocketConnection

- (void)dealloc
{
    [self disconnect];
}

- (instancetype)initWithDelegate:(id<MBSocketConnectionDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (BOOL)isConnected
{
    return [self.gcdSocket isConnected];
}

- (BOOL)isDisconnected
{
    return [self.gcdSocket isDisconnected];
}

- (void)disconnect
{
    if (self.gcdSocket) {
        [self.gcdSocket disconnect];
        self.gcdSocket.delegate = nil;
        self.gcdSocket = nil;
    }
}

- (void)connectWithModel:(MBSocketConnectionModel *)model
{
    if (!self.gcdSocket) {
        self.gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:[MBSocketTools socketQueue]];
        self.gcdSocket.IPv4PreferredOverIPv6 = NO;
    }
    if ([self isDisconnected] && !kIsEmptyString(model.host)) {
        self.connectModel = model;
        NSError *error = nil;
        model.beginConnectTime = [[NSDate date] timeIntervalSince1970] * 1000;
        [self.gcdSocket connectToHost:model.host onPort:model.port withTimeout:model.connectTimeout error:&error];
    }
}

- (void)sendMessage:(NSData *)message
{
    [self.gcdSocket writeData:[message copy] withTimeout:self.connectModel.messageTimeout tag:kSocketMessageWriteTag];
}

- (void)readSocket:(GCDAsyncSocket *)socket length:(NSUInteger)length tag:(long)tag
{
    if (socket) {
        [socket readDataToLength:length withTimeout:-1 tag:tag];
    } else {
        NSLog(@"readSocket socket is nil");
    }
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketConnectionrDidConnect:)]) {
        [self.delegate socketConnectionrDidConnect:self];
    }
    [self readSocket:sock length:kSocketMessageHeaderLength tag:kSocketMessageHeaderTag];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketConnectionDidDisconnect:error:)]) {
        [self.delegate socketConnectionDidDisconnect:self error:err];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketConnection:receiveData:tag:)]) {
        [self.delegate socketConnection:self receiveData:data tag:tag];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketConnection:didWriteDataWithTag:)]) {
        [self.delegate socketConnection:self didWriteDataWithTag:tag];
    }
}

@end
