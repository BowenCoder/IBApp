//
//  NSColor.h
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSColor : NSObject

/**
 *  @brief  随机颜色
 *
 *  @return UIColor
 */
+ (UIColor *)randomColor;

/**
 设置十六进制颜色
 
 @param hexString 十六进制颜色字符
 @return 颜色
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;

/**
 *  @brief  渐变颜色
 *
 *  @param c1     开始颜色
 *  @param c2     结束颜色
 *  @param height 渐变高度
 *
 *  @return 渐变颜色
 */
+ (UIColor*)gradientFromColor:(UIColor*)c1 toColor:(UIColor*)c2 withHeight:(int)height;

@end
