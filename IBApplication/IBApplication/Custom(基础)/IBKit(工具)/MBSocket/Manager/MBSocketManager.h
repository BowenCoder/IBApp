//
//  MBSocketManager.h
//  IBApplication
//
//  Created by Bowen on 2020/6/12.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBSocketCMDType.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBSocketManager : NSObject

@property (nonatomic, strong) NSDictionary *atomDict; // 原子参数
@property (nonatomic, assign) NSInteger appId; // App的标志，向服务端申请
@property (nonatomic, copy) NSString *url; // 请求长链接服务的地址

+ (instancetype)sharedManager;

/**
 断开连接
 */
- (void)disconnect;

/**
 建立连接
 */
- (void)connect;

/**
 发送消息
 @param data 消息内容
 @param compeletion 接收到长链消息的回调
 */
- (void)sendData:(NSDictionary *)data compeletion:(MBSocketRspCallback)compeletion;

/**
 注册长链接消息
 
 @param target 绑定对象
 @param ev b.ev
 @param tp m.tp
 @param compeletion 接收到长链消息的回调
 */
- (void)registerMessageWithTarget:(id)target
                               ev:(NSString *)ev
                               tp:(NSString *)tp
                      compeletion:(MBSocketRspCallback)compeletion;

/**
 移除长链接消息
 */
- (void)removeRegisterMessage:(NSString *)ev tp:(NSString *)tp;

@end

NS_ASSUME_NONNULL_END
