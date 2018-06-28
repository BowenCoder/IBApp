//
//  UIView+Effect.h
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 动画效果类型 */
typedef NS_ENUM(NSInteger, UIViewAnimationType) {
    UIViewAnimationTypeOpen,
    UIViewAnimationTypeClose
};

/** 震动方向 */
typedef NS_ENUM(NSInteger, UIViewShakeDirection) {
    UIViewShakeDirectionHorizontal = 0,
    UIViewShakeDirectionVertical
};

/** 移动方向 */
typedef NS_ENUM(NSInteger, UIViewAnimationDirection) {
    UIViewAnimationDirectionTop,
    UIViewAnimationDirectionRight,
    UIViewAnimationDirectionBottom,
    UIViewAnimationDirectionLeft
};

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

@interface UIView (Animation)

/**
 视图震动效果
 */
- (void)shake;

/**
 *  扩散动画(点击视图水波纹扩散效果)
 *
 *  @param point      动画开始的点
 *  @param duration   动画时间
 *  @param type       动画的类型
 *  @param color      动画的颜色
 *  @param completion 动画结束后的代码快
 */
- (void)addAnimationAtPoint:(CGPoint)point duration:(NSTimeInterval)duration type:(UIViewAnimationType)type color:(UIColor *)color completion:(void (^)(BOOL finished))completion;

+ (void)zoom:(UIView *)view duration:(float)duration isIn:(BOOL)isIn;

+ (void)fade:(UIView *)view duration:(float)duration isIn:(BOOL)isIn;

+ (void)move:(UIView *)view duration:(float)duration distance:(CGFloat)distance direction:(UIViewAnimationDirection)direction;

+ (void)rotate:(UIView *)view duration:(float)duration angle:(int)angle;



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

