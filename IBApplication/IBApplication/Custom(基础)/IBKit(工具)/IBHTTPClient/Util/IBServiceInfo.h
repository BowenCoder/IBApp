//
//  IBServiceInfo.h
//  IBApplication
//
//  Created by Bowen on 2019/7/1.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 1、服务环境配置
 2、ServiceInfo刷新
 注意点：1、先设置环境，再刷新
        2、在willFinishLaunching初始化
 */

NS_ASSUME_NONNULL_BEGIN

@interface IBServiceInfo : NSObject

/**
 开始刷新ServerInfo
 */
- (void)refreshServiceInfo;

/**
 停止刷新ServerInfo
 */
- (void)stopRefresh;

@end

NS_ASSUME_NONNULL_END

//=========================== 老版本 =============================//

// 内部版本号 每次发版递增
#define KVersionCode 1

/*
 将项目中所有的接口写在这里,方便统一管理,降低耦合
 
 这里通过宏定义来切换你当前的服务器类型,
 将你要切换的服务器类型宏后面置为真(即>0即可),其余为假(置为0)
 */
#define IB_DEVELOP_SEVER_OPEN    0
#define IB_TEST_SEVER_OPEN       1
#define IB_PRODUCT_SEVER_OPEN    0

#if IB_DEVELOP_SEVER_OPEN

/**开发服务器*/
#define IBBaseurl @"http://192.168.20.31:20000/shark-miai-service"

#elif IB_TEST_SEVER_OPEN

/**测试服务器*/
#define IBBaseurl @"http://192.168.20.31:20000/shark-miai-service"

#elif IB_PRODUCT_SEVER_OPEN

/**生产服务器*/
#define IBBaseurl @"http://192.168.20.31:20000/shark-miai-service"

#endif
