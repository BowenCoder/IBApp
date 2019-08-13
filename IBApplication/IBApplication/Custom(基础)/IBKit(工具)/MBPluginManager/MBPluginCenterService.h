//
//  MBPluginCenterService.h
//  IBApplication
//
//  Created by Bowen on 2019/8/13.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MBPluginCenterServiceProtocol <NSObject>

/**
 注册一个类：重复注册将覆盖前面注册的类
 按需实例化

 @param service 协议
 @param implClass 类
 */
- (void)registerProtocol:(Protocol *)service implClass:(Class)implClass;

/**
 注册一个实例：重复注册将覆盖前面注册的实例
 
 @param service service description
 @param implInstance 默认持有该impInstance，注意引用循环
 */
- (void)registerProtocol:(Protocol *)service implInstance:(id)implInstance;

/**
 返回一个已经创建好的对象，如果没有则创建一个返回
 
 @param protocol protocol description
 @return return value description
 */
- (id)service:(Protocol *)protocol;

/**
 移除插件

 @param service 协议
 */
- (void)removeService:(Protocol *)service;

/**
 清空：清空所有注册的协议
 */
- (void)clear;

@end



/**
 插件服务提供者
 */
@interface MBPluginCenterService : NSObject <MBPluginCenterServiceProtocol>


@end

NS_ASSUME_NONNULL_END
