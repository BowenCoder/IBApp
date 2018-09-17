//
//  IBHelper.h
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IBHelper : NSObject

/**
 *  @brief  NSData 转成UTF8 字符串
 *
 *  @param data 二进制
 *
 *  @return 转成UTF8 字符串
 */
+ (NSString *)UTF8String:(NSData *)data;

/**
 *  @brief NSDictionary转换成JSON字符串
 *
 *  @param dict 字典
 *
 *  @return  JSON字符串
 */
+ (NSString *)JSONStringFromDict:(NSDictionary *)dict;

/**
 *  @brief NSArray转换成JSON字符串
 *
 *  @param array 字典
 *
 *  @return  JSON字符串
 */
+ (NSString *)JSONStringFromArray:(NSArray *)array;

/**
 *  @brief  将url参数转换成NSDictionary
 *
 *  @param query url参数
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)dictionaryWithURLQuery:(NSString *)query;

/**
 *  @brief  将NSDictionary转换成url参数字符串
 *
 *  @param  params url参数
 *
 *  @return url 参数字符串
 */
+ (NSString *)URLQueryString:(NSDictionary *)params;

@end



