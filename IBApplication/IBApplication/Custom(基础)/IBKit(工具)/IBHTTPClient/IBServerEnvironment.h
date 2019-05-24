//
//  IBServerEnvironment.h
//  IBApplication
//
//  Created by Bowen on 2019/5/24.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, IBNetworkEnvironment) {
    IBNetworkEnvNotDefined = 0,
    IBNetworkEnvTest,    // 测试环境
    IBNetworkEnvDevelop, // 开发环境
    IBNetworkEnvProduct, // 生产环境
};

@interface IBServerEnvironment : NSObject

// 环境配置，在外部初始化
@property (nonatomic, assign) IBNetworkEnvironment env;

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
