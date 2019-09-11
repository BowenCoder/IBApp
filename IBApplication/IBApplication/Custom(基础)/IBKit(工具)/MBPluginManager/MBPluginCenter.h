//
//  MBPluginCenter.h
//  IBApplication
//
//  Created by Bowen on 2019/8/13.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBServiceManager.h"
#import "MBContext.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MBPluginCenterProtocol <NSObject>

- (void)viewDidLoad:(MBContext *)context;

- (void)viewWillAppear:(MBContext *)context;

- (void)viewDidAppear:(MBContext *)context;

- (void)viewWillDisappear:(MBContext *)context;

- (void)viewDidDisappear:(MBContext *)context;

- (void)pluginWillDealloc:(MBContext *)context;

- (void)didReceiveMemoryWarning;

- (void)didEnterBackground;

- (void)didBecomeActive;

@end

/**
 插件管理中心
 */
@interface MBPluginCenter : NSObject <MBPluginCenterProtocol>

- (void)registerPlugin:(id<MBPluginCenterProtocol>)module;

- (void)unregisterPlugin:(id<MBPluginCenterProtocol>)module;

- (id<MBServiceManagerProtocol>)service;

/**
 返回一个已经创建好的对象，如果没有则创建一个返回
 
 @param protocol protocol description
 @return return value description
 */
- (id)serviceInstance:(Protocol *)protocol;

/**
 彻底删除某个协议的所有实例以及注册
 
 @param protocol protocol description
 */
- (void)removeService:(Protocol *)protocol;

/**
 清空：清空所有注册的协议
 */
- (void)clearService;

@end

NS_ASSUME_NONNULL_END
