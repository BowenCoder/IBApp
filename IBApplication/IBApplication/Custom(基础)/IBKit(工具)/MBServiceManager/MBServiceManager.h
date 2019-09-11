//
//  MBServiceManager.h
//  IBApplication
//
//  Created by Bowen on 2019/9/11.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MBServiceManagerProtocol <NSObject>

/**
 注册一个类：重复注册将覆盖前面注册的类
 按需实例化
 
 @param protocol 协议
 @param implClass 类
 */
- (void)registerProtocol:(Protocol *)protocol implClass:(Class)implClass;

/**
 注册一个实例：重复注册将覆盖前面注册的实例
 
 @param protocol service description
 @param implInstance 默认持有该impInstance，注意引用循环
 */
- (void)registerProtocol:(Protocol *)protocol implInstance:(id)implInstance;

/**
 返回一个已经创建好的对象，如果没有则创建一个返回
 
 @param protocol protocol description
 @return return value description
 */
- (id)serviceInstance:(Protocol *)protocol;

/**
 只移除初始化实例，注册是类不移除。
 
 @param protocol 协议
 */
- (void)removeInstance:(Protocol *)protocol;

/**
 移除实例和注册的类
 
 @param protocol 协议
 */
- (void)removeService:(Protocol *)protocol;

/**
 清空：清空所有注册的协议
 */
- (void)clear;

@end

@interface MBServiceManager : NSObject <MBServiceManagerProtocol>

/**
 注意，此对象仅供全局服务使用。局部生命周期使用init初始化
 */
+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
