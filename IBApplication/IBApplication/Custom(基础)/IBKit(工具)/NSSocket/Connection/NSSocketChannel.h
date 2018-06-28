//
//  NSSocketChannel.h
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSSocketConnection.h"
#import "NSSocketPacket.h"

@class NSSocketChannel;

@protocol NSSocketChannelDelegate <NSObject>
@required
- (void)channelOpened:(NSSocketChannel *)channel host:(NSString *)host port:(int)port;
- (void)channelClosed:(NSSocketChannel *)channel error:(NSError *)error;
- (void)channel:(NSSocketChannel *)channel received:(NSDownloadDataPacket *)packet;

@end

@interface NSSocketChannel : NSSocketConnection

@property (nonatomic, strong) NSUploadDataPacket *heartbeatPacket;

@property (nonatomic, weak) id<NSSocketChannelDelegate> delegate;

- (void)openConnection;
- (void)closeConnection;

- (void)asyncSendPacket:(NSUploadDataPacket *)packet;

@end
