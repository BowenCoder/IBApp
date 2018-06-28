//
//  NSCharacters.h
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSCharacters : NSObject

#pragma mark - contain

/**
 *  @brief  判断URL中是否包含中文
 *
 *  @param string 字符串
 *
 *  @return 是否包含中文
 */
+ (BOOL)containChinese:(NSString *)string;

/**
 *  @brief 是否包含字符串
 *
 *  @param string 被包的字符串
 *  @param bag 包含的字符串
 *
 *  @return YES, 包含;
 */
+ (BOOL)containString:(NSString *)string inString:(NSString *)bag;

#pragma mark - Size

/**
 *  @brief 计算文字的高度
 *
 *  @param text  文本
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 *
 */
+ (CGFloat)height:(NSString *)text font:(UIFont *)font width:(CGFloat)width;

/**
 *  @brief 计算文字的宽度
 *
 *  @param text   文本
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 *
 */
+ (CGFloat)width:(NSString *)text font:(UIFont *)font height:(CGFloat)height;

/**
 *  @brief 计算文字的大小
 *
 *  @param text  文本
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 *
 */
+ (CGSize)size:(NSString *)text font:(UIFont *)font width:(CGFloat)width;

/**
 *  @brief 计算文字的大小
 *
 *  @param text   文本
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 *
 */
+ (CGSize)size:(NSString *)text font:(UIFont *)font height:(CGFloat)height;

#pragma mark - Clear

/**
 *  @brief  清除html标签
 *
 *  @param  html html字符串
 *
 *  @return 清除后的结果
 */
+ (NSString *)clearHTML:(NSString *)html;

/**
 *  @brief  清除js脚本
 *
 *  @param  js js字符串
 *
 *  @return 清楚js后的结果
 */
+ (NSString *)clearJS:(NSString *)js;

/**
 *  @brief  清除空格，并判断是否过滤特殊字符
 *
 *  @param  text   字符串
 *  @param  filter 是否过滤
 *
 *  @return 清楚js后的结果
 */
+ (NSString *)clearWhitespace:(NSString *)text filter:(BOOL)filter;

/**
 调整html返回的字符串的内容格式
 
 @param content html字符串
 @return 调整后的字符串
 */
+ (NSString *)adjustHTMLFormat:(NSString *)content;

#pragma mark - Regex

/** 手机号有效性 */
+ (BOOL)isMobileNumber:(NSString *)text;

/** 邮箱的有效性 */
+ (BOOL)isEmail:(NSString *)text;

/** 车牌号的有效性 */
+ (BOOL)isCarNumber:(NSString *)text;

/** 银行卡的有效性 */
+ (BOOL)isValidBankCard:(NSString *)text;

/** IP地址有效性 */
+ (BOOL)isIPAddress:(NSString *)text;

/** Mac地址有效性 */
+ (BOOL)isMacAddress:(NSString *)text;

/** 网址有效性 */
+ (BOOL)isValidUrl:(NSString *)text;

/** 纯汉字 */
+ (BOOL)isValidChinese:(NSString *)text;

/** 邮政编码 */
+ (BOOL)isValidPostcode:(NSString *)text;

/** 工商税号 */
+ (BOOL)isValidTaxNumber:(NSString *)text;

/** 简单的身份证有效性 */
+ (BOOL)simpleVerifyIDCardNumber:(NSString *)text;

/** 精确的身份证号码有效性检测
 
 *  @param value 身份证号
 */
+ (BOOL)accurateVerifyIDCardNumber:(NSString *)value;

/**
 @brief     是否符合最小长度、最长长度，是否包含中文,首字母是否可以为数字
 
 @param     text     文本
 @param     minLenth 账号最小长度
 @param     maxLenth 账号最长长度
 @param     chinese  是否包含中文
 @param     firstNotDigtal 首字母不能为数字
 
 @return    正则验证成功返回YES, 否则返回NO
 */
+ (BOOL)isValidText:(NSString *)text
           minLenth:(NSInteger)minLenth
           maxLenth:(NSInteger)maxLenth
            chinese:(BOOL)chinese
     firstNotDigtal:(BOOL)firstNotDigtal;

/**
 @brief     是否符合最小长度、最长长度，是否包含中文,数字，字母，其他字符，首字母是否可以为数字
 
 @param     text     文本
 @param     minLenth 账号最小长度
 @param     maxLenth 账号最长长度
 @param     chinese  是否包含中文
 @param     digtal   包含数字
 @param     letter   包含字母
 @param     otherCharacter 包含其他字符
 @param     firstNotDigtal 首字母不能为数字
 
 @return    正则验证成功返回YES, 否则返回NO
 */
+ (BOOL)isValidText:(NSString *)text
           minLenth:(NSInteger)minLenth
           maxLenth:(NSInteger)maxLenth
            chinese:(BOOL)chinese
             digtal:(BOOL)digtal
             letter:(BOOL)letter
     otherCharacter:(NSString *)otherCharacter
     firstNotDigtal:(BOOL)firstNotDigtal;


@end
