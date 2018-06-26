//
//  UIThemeManager.h
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Theme)

/*!
 @brief  获取控件默认的背景颜色
 @return 控件默认的背景颜色
 */
+ (UIColor *)defaultBGColor;

/*!
 @brief  获取APP默认主题颜色
 @return APP默认主题颜色
 */
+ (UIColor *)appThemeColor;

/*!
 @brief  获取分割线默认颜色
 @return 分割线默认颜色
 */
+ (UIColor *)lineColor;

/*!
 @brief  获取默认全局字体颜色
 @return 默认全局字体颜色
 */
+ (UIColor *)defaultFontColor;

/*!
 @brief  获取一级字体颜色
 @return 一级字体颜色
 */
+ (UIColor *)firstFontColor;

/*!
 @brief  获取二级字体颜色
 @return 二级字体颜色
 */
+ (UIColor *)secondFontColor;

@end

@interface UIImage (Theme)

/*!
 @brief  获取控件默认的背景图
 @return 控件默认的背景图
 */
+ (UIImage *)defaultBGImage;

@end

@interface UIFont (Theme)

/*!
 @brief  获取控件默认的字体
 @return 控件默认的字体
 */
+ (UIFont *)defaultFont;

/*!
 @brief  获取一级字体
 @return 一级字体
 */
+ (UIFont *)firstFont;

/*!
 @brief  获取二级字体
 @return 二级字体
 */
+ (UIFont *)secondFont;

@end
