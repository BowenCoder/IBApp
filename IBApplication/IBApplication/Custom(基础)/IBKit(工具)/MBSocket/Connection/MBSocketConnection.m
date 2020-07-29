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
    if ([self isConnected]) {
        self.gcdSocket.delegate = nil;
        [self.gcdSocket disconnect];
        self.gcdSocket = nil;
    }
}

- (void)connectWithHost:(NSString *)host timeout:(NSTimeInterval)timeout port:(uint16_t)port
{
    if (!self.gcdSocket) {
        self.gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:[MBSocketTools socketQueue]];
        self.gcdSocket.IPv4PreferredOverIPv6 = NO;
    }
    
    if ([self isDisconnected] && host) {
        NSError *error;
        [self.gcdSocket connectToHost:host onPort:port withTimeout:timeout error:&error];
        if (error) {
            [self socketDidDisconnect:self.gcdSocket withError:error];
        }
    }
}

- (void)sendMessage:(NSData *)message timeout:(NSTimeInterval)timeout tag:(long)tag
{
    [self.gcdSocket writeData:message withTimeout:timeout tag:tag];
}

- (void)readDataToLength:(NSUInteger)length timeout:(NSTimeInterval)timeout tag:(long)tag;
{
    if ([self isConnected]) {
        [self.gcdSocket readDataToLength:length withTimeout:timeout tag:tag];
    } else {
        NSError *error = [NSError errorWithDomain:@"socket is disconnected" code:MBSocketErrorDisconnected userInfo:nil];
        [self didFailWithError:error];
    }
}

- (void)didFailWithError:(NSError *)error
{
    if (!error) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketConnection:fail:)]) {
        [self.delegate socketConnection:self fail:error];
    }
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketConnectionrDidConnect:)]) {
        [self.delegate socketConnectionrDidConnect:self];
    }
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
