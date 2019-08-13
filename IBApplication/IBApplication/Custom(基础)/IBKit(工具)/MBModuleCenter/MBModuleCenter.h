//
//  MBModuleCenter.h
//  IBApplication
//
//  Created by Bowen on 2019/5/26.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 模块中心，拆分AppDelegate的功能
 */
@interface MBModuleCenter : NSObject <MBModuleProtocol>

+ (instancetype)defaultCenter;

/**
 注册模块

 @param protocol 遵守MBModuleProtocol协议的对象
 */
- (void)registerModule:(id<MBModuleProtocol>)protocol;

/**
 解除注册模块

 @param protocol 遵守MBModuleProtocol协议的对象
 */
- (void)unregisterModule:(id<MBModuleProtocol>)protocol;

/**
 执行一个block
 
 @param block block description
 */
- (void)excuteBlock:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
