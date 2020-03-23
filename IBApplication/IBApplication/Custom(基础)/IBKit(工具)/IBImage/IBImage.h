//
//  IBPicture.h
//  IBApplication
//
//  Created by BowenCoder on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  水印方向
 */
typedef NS_ENUM(NSInteger, ImageWaterDirect) {
    //左上
    ImageWaterDirectTopLeft = 0,
    //右上
    ImageWaterDirectTopRight,
    //左下
    ImageWaterDirectBottomLeft,
    //右下
    ImageWaterDirectBottomRight,
    //正中
    ImageWaterDirectCenter
};

typedef NS_ENUM(NSInteger, IBImageGradientType) {
    IBImageGradientTopToBottom = 0,
    IBImageGradientLeftToRight,
    IBImageGradientLeftTopToRightBottom,
    IBImageGradientLeftBottomToRightTop,
};

@interface IBImage : NSObject

#pragma mark - Basic

/**
 *  @brief  根据mainBundle中的文件名读取图片
 *
 *  @param name 图片名
 *
 *  @return 无缓存的图片
 */
+ (UIImage *)imageWithFileName:(NSString *)name;

/**
 *  @brief  根据自定义bundle中的文件名读取图片，注意imageWithContentsOfFile无法读取Assets中图片
 *
 *  @param name 图片名
 *  @param bundleName 自定义bundle的名字
 *
 *  @return 无缓存的图片
 */
+ (UIImage *)imageWithName:(NSString *)name inBundle:(NSString *)bundleName;

/**
 *  @brief  根据颜色生成纯色图片
 *
 *  @param color 颜色
 *
 *  @return 纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  @brief 根据颜色和大小生成纯色图片
 *
 *  @param color 图片颜色
 *
 *  @param size 图片大小
 *
 *  @return 纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 *  @brief 拉伸图片
 *
 *  @param name 图片名字
 *
 *  @return 拉伸好的图片
 */
+ (UIImage *)stretchImageNamed:(NSString *)name;

/**
 *  @brief 拉伸图片
 *
 *  @param image 要拉伸的图片
 *
 *  @return 拉伸好的图片
 */
+ (UIImage *)stretchImageWithImage:(UIImage *)image;

/**
 *  压缩图片，不带圆角
 *
 *  @param image   要压缩的图片
 *  @param newSize 压缩后的图片的像素尺寸
 *
 *  @return 压缩好的图片
 */
+ (UIImage *)resizedImage:(UIImage*)image size:(CGSize)newSize;

/**
 *  压缩图片，带圆角。尺寸不等比，存在变形
 *
 *  @param image   要压缩的图片
 *  @param newSize 压缩后的图片的像素尺寸
 *  @param radius  圆角
 *
 *  @return 压缩好的图片
 */
+ (UIImage *)resizedImage:(UIImage *)image size:(CGSize)newSize radius:(CGFloat)radius;

/**
 中心裁剪图片，不存在变形

 @param image 图片
 @param newSize 尺寸
 @return 图片
 */
+ (UIImage *)clipImage:(UIImage *)image size:(CGSize)newSize;

/**
 裁剪图片，不存在变形
 
 @param image 图片
 @param frame frame
 @return 图片
 */
+ (UIImage *)clipImage:(UIImage *)image frame:(CGRect)frame;

/**
 判断相等

 @param image 一种图片
 @param anotherImage 另一种图片
 @return 是否相等
 */
+ (BOOL)equalToImage:(UIImage *)image anotherImage:(UIImage *)anotherImage;

#pragma mark - Special

/**
 *  @brief 图片翻转 :YES,水平翻转，NO，垂直翻转
 *
 *  @param image 要翻转的图片
 *
 *  @return 翻转后的图片
 */
+ (UIImage *)flip:(UIImage *)image horizontal:(BOOL)horizontal;

/**
 *  @brief 修正拍照图片方向
 *
 *  @param image 要修改方向的图片
 *
 *  @return 修正后的图片
 */
+ (UIImage *)fixOrientation:(UIImage *)image;

/**
 *  根据image返回一个圆形的头像
 *
 *  @param image     要切割的头像
 *  @param border    边框的宽度
 *  @param color     边框的颜色
 *
 *  @return 切割好的头像
 */
+ (UIImage *)captureCircleImage:(UIImage *)image borderWidth:(CGFloat)border borderColor:(UIColor *)color;

/**
 改变图片背景色
 
 @param image     图片
 @param tintColor 颜色
 @return 图片
 */
+ (UIImage *)blendImage:(UIImage *)image tintColor:(UIColor *)tintColor;

/// 改变图片透明度
/// @param image 图片
/// @param alpha 透明度
+ (UIImage *)blendImage:(UIImage *)image alpha:(CGFloat)alpha;

/// 生成类似UIBlurEffectStyleLight的图片
/// @param image 图片
+ (UIImage *)lightEffectImage:(UIImage *)image;

/// 生成类似UIBlurEffectStyleExtraLight的图片
/// @param image 图片
+ (UIImage *)extraLightEffectImage:(UIImage *)image;

/// 生成类似UIBlurEffectStyleDark的图片
/// @param image 图片
+ (UIImage *)darkEffectImage:(UIImage *)image;

/// 改变颜色生成毛玻璃
/// @param inputImage 图片
/// @param tintColor 颜色
+ (UIImage *)tintEffectImage:(UIImage*)inputImage tintColor:(UIColor *)tintColor;

/// 生成毛玻璃效果的图片，自定义尺度大
/// @param inputImage 图片
/// @param blurValue 模糊指数
/// @param tintColor 颜色
/// @param saturationFactor 饱和度
/// @param maskImage 遮罩
+ (UIImage *)blurredImage:(UIImage *)inputImage blurValue:(CGFloat)blurValue tintColor:(UIColor *)tintColor saturationFactor:(CGFloat)saturationFactor maskImage:(UIImage *)maskImage;

/**
 *  生成毛玻璃效果的图片
 *
 *  @param image      要模糊化的图片
 *  @param blurValue 模糊化指数0~1
 *
 *  @return 返回模糊化之后的图片
 */
+ (UIImage *)blurredImage:(UIImage *)image blurValue:(CGFloat)blurValue;

/**
 生成渐变色图片

 @param size 大小
 @param colors 颜色数组
 @param percents 颜色数组改变的位置，每个对象0~1之间
 @param gradientType 渐变类型
 @return 图片
 */
+ (UIImage *)gradientImageWithSize:(CGSize)size gradientColors:(NSArray *)colors percentage:(NSArray *)percents gradientType:(IBImageGradientType)gradientType;

#pragma mark - Merge

/**
 *  @brief  合并两个图片
 *
 *  @param firstImage  一个图片
 *  @param secondImage 二个图片
 *
 *  @return 合并后图片
 */
+ (UIImage*)mergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage;

/**
 *  加文字水印
 */
+ (UIImage *)water:(UIImage *)image text:(NSString *)text direction:(ImageWaterDirect)direction fontColor:(UIColor *)fontColor fontPoint:(CGFloat)fontPoint marginXY:(CGPoint)marginXY;

/**
 *  加图片水印
 */
+ (UIImage *)water:(UIImage *)image waterImage:(UIImage *)waterImage direction:(ImageWaterDirect)direction waterSize:(CGSize)waterSize marginXY:(CGPoint)marginXY;

@end
