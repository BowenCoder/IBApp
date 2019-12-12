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

/**
 *  获取token等信息 (登录成功后调用)
 */
- (void)requestData;

/**
 *  获取头部信息
 */
- (NSDictionary *)headerFields;


@end

NS_ASSUME_NONNULL_END
