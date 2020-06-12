//
//  MBSocketClientModel.h
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBSocketClientModel : NSObject

/**
 连接服务器的domain或ip,默认@""
 */
@property (nonatomic, copy) NSString *host;
/**
 连接服务器的端口,默认0
 */
@property (nonatomic, assign) NSInteger port;
/**
 开始连接时间
 */
@property (nonatomic, assign) NSTimeInterval beginConnectTime;
/**
 连接服务器的超时时间（单位秒s），默认为15秒
 */
@property (nonatomic, assign) NSTimeInterval connectTimeout;
/**
 心跳定时间隔，默认为30秒
 */
@property (nonatomic, assign) NSTimeInterval heartbeatInterval;
/**
消息超时时间
*/
@property (nonatomic, assign) NSTimeInterval messageTimeout;
/**
 重连最大重连次数,默认100次
 */
@property (nonatomic, assign) NSInteger retryConnectMaxCount;
/**
 重连的时间间隔,默认5秒
 */
@property (nonatomic, assign) NSTimeInterval retryConnectInterval;


@end

NS_ASSUME_NONNULL_END
