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
#import "MBLogger.h"

@interface MBSocketClient () <MBSocketConnectionDelegate>

@property (nonatomic, strong) MBSocketConnection *connection;
@property (nonatomic, strong) MBSocketReceivePacket *receivePacket;

@end

@implementation MBSocketClient

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
    [self.connection disconnect];
}

- (void)connectWithModel:(MBSocketConnectionModel *)model
{
    [self.connection connectWithHost:model.host timeout:15 port:model.port];
}

#pragma mark - MBSocketConnectionDelegate

/// 发生其他错误
- (void)socketConnection:(MBSocketConnection *)connection fail:(NSError *)error
{
    
}

/// 连接成功回调
- (void)socketConnectionrDidConnect:(MBSocketConnection *)connection
{
    [self readDataToLength:kSocketMessageHeaderLength tag:kSocketMessageHeaderTag];
}

/// 连接失败回调
- (void)socketConnectionDidDisconnect:(MBSocketConnection *)connection error:(NSError *)error
{
    
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
    
}


#pragma mark - getter

- (MBSocketConnection *)connection {
    if(!_connection){
        _connection = [[MBSocketConnection alloc] initWithDelegate:self];
    }
    return _connection;
}

@end
