//
//  NSDictionary+Ext.h
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONString)

/**
 *  @brief NSDictionary转换成JSON字符串
 *
 *  @return  JSON字符串
 */
- (NSString *)JSONString;

@end

@interface NSDictionary (URL)

/**
 *  @brief  将url参数转换成NSDictionary
 *
 *  @param query url参数
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)dictionaryWithURLQuery:(NSString *)query;

/**
 *  @brief  将NSDictionary转换成url 参数字符串
 *
 *  @return url 参数字符串
 */
- (NSString *)URLQueryString;

@end


