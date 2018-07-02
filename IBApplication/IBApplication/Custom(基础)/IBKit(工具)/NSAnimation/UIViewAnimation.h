//
//  UIViewAnimation.h
//  IBApplication
//
//  Created by Bowen on 2018/6/29.
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
    UIViewAnimationTop,
    UIViewAnimationRight,
    UIViewAnimationBottom,
    UIViewAnimationLeft,
    UIViewAnimationTopLeft,
    UIViewAnimationTopRight,
    UIViewAnimationBottomLeft,
    UIViewAnimationBottomRight
};

typedef void(^UIViewAnimationHandle)(CAAnimation *animation);

@interface UIViewAnimation : NSObject

/** 真实移动视图（解决移动后的视图是否响应问题） */
@property (nonatomic, assign) BOOL moveModelLayer;
/** 移除动画 */
@property (nonatomic, assign) BOOL removeAnimation;

+ (CGPoint)viewCenter:(CGRect)enclosingViewFrame viewFrame:(CGRect)viewFrame viewCenter:(CGPoint)viewCenter direction:(UIViewAnimationDirection)direction;

+ (CGPoint)screenCenter:(CGRect)viewFrame viewCenter:(CGPoint)viewCenter direction:(UIViewAnimationDirection)direction;

+ (CGPoint)overshootPoint:(CGPoint)point direction:(UIViewAnimationDirection)direction threshold:(CGFloat)threshold;

+ (CGFloat)maxBorderDiameterForPoint:(CGPoint)point onView:(UIView *)view;

@end

@interface UIViewAnimation (Animation)

/** 视图震动效果 */
+ (void)shake:(UIView *)view;

/**
 *  扩散动画(点击视图水波纹扩散效果)
 *
 *  @param view       要执行动画的view
 *  @param point      动画开始的点
 *  @param duration   动画时间
 *  @param type       动画的类型
 *  @param color      动画的颜色
 *  @param completion 动画结束后的代码快
 */
+ (void)spread:(UIView *)view startPoint:(CGPoint)point duration:(NSTimeInterval)duration type:(UIViewAnimationType)type color:(UIColor *)color completion:(void (^)(BOOL finished))completion;

/** 缩放 */
+ (void)zoom:(UIView *)view duration:(float)duration isIn:(BOOL)isIn completion:(void (^)(void))completion;

/** 淡入淡出 */
+ (void)fade:(UIView *)view duration:(float)duration isIn:(BOOL)isIn completion:(void (^)(void))completion;

/** 旋转 */
+ (void)rotate:(UIView *)view duration:(float)duration angle:(NSInteger)angle completion:(void (^)(void))completion;

/** 移动 */
+ (void)move:(UIView *)view duration:(float)duration distance:(CGFloat)distance direction:(UIViewAnimationDirection)direction completion:(void (^)(void))completion; 

@end


/**
 核心动画操作的是呈现图层，实际上模型图层没有变
 注意点，载入屏幕，视图需要在开始时添加上去；移出屏幕，视图需要在结束时移除
 */
@interface UIViewAnimation (CoreAnimation)

/**
 移动动画

 @param view 要执行动画的view
 @param enclosingView 在哪个view中执行动画
 @param direction 动画方向
 @param duration 动画时间
 @param startHandle 开始时回调
 @param endHandle 结束时回调
 @param isIn YES,载入动画；NO,移除动画
 @return 动画
 */
- (CAAnimation *)slideAnimation:(UIView *)view
                         inView:(UIView *)enclosingView
                      direction:(UIViewAnimationDirection)direction
                       duration:(NSTimeInterval)duration
                          start:(UIViewAnimationHandle)startHandle
                            end:(UIViewAnimationHandle)endHandle
                           isIn:(BOOL)isIn;

- (CAAnimation *)fadeAnimation:(UIView *)view
                      duration:(NSTimeInterval)duration
                         start:(UIViewAnimationHandle)startHandle
                           end:(UIViewAnimationHandle)endHandle
                          isIn:(BOOL)isIn;

- (CAAnimation *)backAnimation:(UIView *)view
                        inView:(UIView *)enclosingView
                     direction:(UIViewAnimationDirection)direction
                      duration:(NSTimeInterval)duration
                         start:(UIViewAnimationHandle)startHandle
                           end:(UIViewAnimationHandle)endHandle
                          fade:(BOOL)fade
                          isIn:(BOOL)isIn;

- (CAAnimation *)popAnimation:(UIView *)view
                     duration:(NSTimeInterval)duration
                        start:(UIViewAnimationHandle)startHandle
                          end:(UIViewAnimationHandle)endHandle
                         isIn:(BOOL)isIn;

- (CAAnimation *)fallAnimation:(UIView *)view
                     duration:(NSTimeInterval)duration
                        start:(UIViewAnimationHandle)startHandle
                          end:(UIViewAnimationHandle)endHandle
                         isIn:(BOOL)isIn;

- (CAAnimation *)flyoutAnimation:(UIView *)view
                        duration:(NSTimeInterval)duration
                           start:(UIViewAnimationHandle)startHandle
                             end:(UIViewAnimationHandle)endHandle;

- (CAAnimationGroup *)animationGroup:(UIView *)view
                          animations:(NSArray *)animations
                            duration:(NSTimeInterval)duration
                               start:(UIViewAnimationHandle)startHandle
                                 end:(UIViewAnimationHandle)endHandle;

@end


