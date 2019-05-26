//
//  IBSecurity.h
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IBSecurity : NSObject

+ (instancetype)sharedInstance;

/**
 *  获取头部信息
 *
 *  @param uri        url description
 *  @return completion completion description
 */
- (NSDictionary *)securityHeadersWithUri:(NSString *)uri;

/**
 *  启动定时获取token等信息 (登录成功后调用)
 */
- (void)start;
/**
 *  清空当前token信息等(一般退出登录时调用)
 */
- (void)clear;


@end

NS_ASSUME_NONNULL_END
