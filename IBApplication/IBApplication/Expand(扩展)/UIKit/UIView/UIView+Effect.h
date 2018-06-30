//
//  UIView+Effect.h
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Effect)

/**
 设置圆角
 
 @param radius 圆角半径
 @param corners 圆角类型
 */
- (void)setCornerRadius:(CGFloat)radius option:(UIRectCorner)corners;

/**
 绘制带圆角的边框

 @param color 边框颜色
 @param width 边框宽度
 @param radius 圆角半径
 */
- (void)setBorderColor:(UIColor *)color width:(CGFloat)width cornerRadius:(CGFloat)radius;

/**
 设置阴影

 @param color 颜色
 @param opacity 阴影的透明度，默认是0   范围 0-1 越大越不透明
 @param offset 阴影偏移量
 @param radius 阴影圆角半径
 @param type 阴影类型

 */
- (void)setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset radius:(CGFloat)radius type:(NSString *)type;

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
- (void)moveAxis:(CGFloat)dx dy:(CGFloat)dy;

- (void)cancelMotionEffect;

@end

