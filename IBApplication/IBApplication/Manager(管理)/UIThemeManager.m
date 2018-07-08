//
//  UIThemeManager.m
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIThemeManager.h"
#import "IBColor.h"
@implementation UIColor (Theme)

/*!
 @brief  获取控件默认的背景颜色
 @return 控件默认的背景颜色
 */
+ (UIColor *)defaultBGColor {
    return [IBColor colorWithHexString:@"f2f2f2"];
}

/*!
 @brief  获取APP默认主题颜色
 @return APP默认主题颜色
 */
+ (UIColor *)appThemeColor {
    return [IBColor colorWithHexString:@"#ff6666"];
}

/*!
 @brief  获取分割线默认颜色
 @return 分割线默认颜色
 */
+ (UIColor *)lineColor {
    return [IBColor colorWithHexString:@"#ededed"];
}

/*!
 @brief  获取默认全局字体颜色
 @return 默认全局字体颜色
 */
+ (UIColor *)defaultFontColor {
    return [UIColor blackColor];
}

/*!
 @brief  获取一级字体颜色
 @return 一级字体颜色
 */
+ (UIColor *)firstFontColor {
    return [IBColor colorWithHexString:@"#1f1f1f"];
}

/*!
 @brief  获取二级字体颜色
 @return 二级字体颜色
 */
+ (UIColor *)secondFontColor {
    return [IBColor colorWithHexString:@"#5c5c5c"];
}

@end

@implementation UIImage (Theme)

/*!
 @brief  获取控件默认的背景图
 @return 控件默认的背景图
 */
+ (UIImage *)defaultBGImage {
    return [UIImage imageNamed:@"nil"];
}

@end

@implementation UIFont (Theme)

/*!
 @brief  获取控件默认的字体
 @return 控件默认的字体
 */
+ (UIFont *)defaultFont {
    return [UIFont systemFontOfSize:12.0f];
}

/*!
 @brief  获取一级字体
 @return 一级字体
 */
+ (UIFont *)firstFont {
    return [UIFont systemFontOfSize:14.0f];
}

/*!
 @brief  获取二级字体
 @return 二级字体
 */
+ (UIFont *)secondFont {
    return [UIFont systemFontOfSize:10.0f];

}

@end
