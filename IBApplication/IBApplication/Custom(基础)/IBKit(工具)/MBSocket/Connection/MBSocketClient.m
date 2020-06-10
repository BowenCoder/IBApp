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

@interface MBSocketClient () <MBSocketConnectionDelegate>

@property (nonatomic, strong) MBSocketConnection *connection;
@property (nonatomic, strong) MBSocketReceivePacket *receivePacket;

@end

@implementation MBSocketClient


- (void)dispatchData
{
    
}

- (void)handleData:(NSData *)data withTag:(long)tag
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
                [self.connection readDataToLength:self.receivePacket.extraHeaderLength tag:kSocketMessageExtraHeaderTag];
            } else if (self.receivePacket.bodyLength > 0) {
                [self.connection readDataToLength:self.receivePacket.bodyLength tag:kSocketMessageBodyTag];
            } else {
                [self.connection readDataToLength:kSocketMessageHeaderLength tag:kSocketMessageHeaderTag];
            }
        }
            break;
        case kSocketMessageExtraHeaderTag:
        {
            [MBSocketPacketDecode decodeExtraHeaderData:self.receivePacket data:data];
            if (self.receivePacket.bodyLength > 0) {
                [self.connection readDataToLength:self.receivePacket.bodyLength tag:kSocketMessageBodyTag];
            } else {
                [self.connection readDataToLength:kSocketMessageHeaderLength tag:kSocketMessageHeaderTag];
            }
        }
            break;
        case kSocketMessageBodyTag:
        {
            [MBSocketPacketDecode decodeBodyData:self.receivePacket data:data];
            [self dispatchData];
            [self.connection readDataToLength:kSocketMessageHeaderLength tag:kSocketMessageHeaderTag];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - MBSocketConnectionDelegate

/// 连接成功回调
- (void)socketConnectionrDidConnect:(MBSocketConnection *)connection
{
    [connection readDataToLength:kSocketMessageHeaderLength tag:kSocketMessageHeaderTag];
}

/// 连接失败回调
- (void)socketConnectionDidDisconnect:(MBSocketConnection *)connection error:(NSError *)error
{
    
}

/// 接收数据回调
- (void)socketConnection:(MBSocketConnection *)connection receiveData:(NSData *)data tag:(long)tag
{
    [self handleData:data withTag:tag];
}

/// 发送成功回调
- (void)socketConnection:(MBSocketConnection *)connection didWriteDataWithTag:(long)tag
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
