//
//  IBColor.h
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IBGradientColorDirection) {
    IBGradientColorHorizontal = 0,
    IBGradientColorVertical,
    IBGradientColorUpwardDiagonal,
    IBGradientColorDownDiagonal
};


@interface IBColor : NSObject

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
 颜色线性渐变

 @param startColor 开始颜色
 @param endColor 结束颜色
 @param direction 方向
 @param size 尺寸
 @return 颜色
 */
+ (UIColor *)linearGradient:(UIColor *)startColor endColor:(UIColor *)endColor direction:(IBGradientColorDirection)direction size:(CGSize)size;

/**
 颜色放射性渐变

 @param centerColor 中心颜色
 @param outColor 外围颜色
 @param size 尺寸
 @return 颜色
 */
+ (UIColor *)radialGradient:(UIColor *)centerColor outColor:(UIColor *)outColor size:(CGSize)size;

/**
 判断颜色是否相等

 @param color 一个颜色
 @param anotherColor 另一个颜色
 @return YES,相等
 */
+ (BOOL)equalToColor:(UIColor *)color anotherColor:(UIColor *)anotherColor;

/**
颜色平滑过渡

@param startColor 开始颜色
@param endColor 结束颜色
@param progress 系数（0.0~1.0）
@return 过渡颜色
*/
+ (UIColor *)transitionColor:(UIColor *)startColor endColor:(UIColor *)endColor progress:(CGFloat)progress;

@end
