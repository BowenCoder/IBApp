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
+ (NSString *)JSONString:(NSDictionary *)dict;

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

@interface IBHelper (NSDataHelper)

/**
 *  是否空数据
 *
 *  @param data 数据
 *
 *  @return 如果数据为nil或者长度为0返回YES
 */
+ (BOOL)isEmptyData:(NSData *)data;

@end

@interface IBHelper (NSDictionaryHelper)

/**
 *  是否空字典
 *
 *  @param dict 字典
 *
 *  @return 如果字典为nil或者元素个数为0返回YES
 */
+ (BOOL)isEmptyDic:(NSDictionary *)dict;

@end

@interface IBHelper (NSArrayHelper)

/**
 *  是否空数组
 *
 *  @param array 数组
 *
 *  @return 如果数组为nil或者元素个数为0返回YES
 */
+ (BOOL)isEmptyArray:(NSArray *)array;

@end

@interface IBHelper (NSStringHelper)

/**
 *  是否空字符串
 *
 *  @param string 字符串
 *
 *  @return 如果字符串为nil或者长度为0返回YES
 */
+ (BOOL)isEmptyString:(NSString *)string;

@end

