//
//  UIView+Effect.h
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, MBViewBorderPosition) {
    MBViewBorderPositionNone      = 0,
    MBViewBorderPositionTop       = 1 << 0,
    MBViewBorderPositionLeft      = 1 << 1,
    MBViewBorderPositionBottom    = 1 << 2,
    MBViewBorderPositionRight     = 1 << 3
};

@interface UIView (Effect)

/**
 设置圆角
 
 @param radius 圆角半径
 @param corners 圆角类型
 */
- (void)mb_setCornerRadius:(CGFloat)radius option:(UIRectCorner)corners;

/**
 绘制带圆角的边框

 @param color 边框颜色
 @param width 边框宽度
 @param radius 圆角半径
 */
- (void)mb_setBorderColor:(UIColor *)color width:(CGFloat)width cornerRadius:(CGFloat)radius;

/**
 设置阴影

 @param color 颜色
 @param opacity 阴影的透明度，默认是0   范围 0-1 越大越不透明
 @param offset 阴影偏移量
 @param radius 阴影圆角半径
 @param type 阴影类型

 */
- (void)mb_setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset radius:(CGFloat)radius type:(NSString *)type;

@end

@interface UIView (MotionEffect)

@property (nonatomic, strong) UIMotionEffectGroup *effectGroup;

/**
 *  添加重力感应效果
 *
 *  调用示例
 *
 *  view.effectGroup = [UIMotionEffectGroup new];
 *  [view moveAxis:dx dy:dy];
 *
 *  @param dx x方向的偏移
 *  @param dy y方向的偏移
 */
- (void)mb_moveAxis:(CGFloat)dx dy:(CGFloat)dy;

- (void)mb_cancelMotionEffect;

@end

@interface UIView (Border)

/// 边框的大小
- (void)mb_setBorderWidth:(CGFloat)borderWidth;

/// 边框的颜色
- (void)mb_setBorderColor:(UIColor *)borderColor;

/// 设置边框类型，支持组合
- (void)mb_setBorderPosition:(MBViewBorderPosition)borderPosition;

/// 表示虚线起始的偏移
- (void)mb_setDashPhase:(CGFloat)dashPhase;

/// 表示“lineWidth，lineSpacing，lineWidth，lineSpacing...”的顺序，至少传 2 个。
- (void)mb_setDashPattern:(NSArray<NSNumber *> *)dashPattern;

/// 边框图层，已经添加到图层上
- (CAShapeLayer *)mb_borderLayer;

@end

NS_ASSUME_NONNULL_END
