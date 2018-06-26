//
//  UIView+Ext.h
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

///< UIView的扩展类
@interface UIView (Ext)

/**
 最底层视图

 @return 视图
 */
- (UIView *)topView;

/**
 移除所有视图
 */
- (void)removeAllSubviews;

/**
 找到当前视图所在的控制器

 @return viewController
 */
- (UIViewController *)viewController;

/**
 设置背景图片

 @param image 图片
 @param pattern YES,占用内存低，但是稍微模糊；NO，占用内存高，但是高清
 */
- (void)setBackgroundImage:(UIImage *)image pattern:(BOOL)pattern;

/**
 画线

 @param points 起始点
 @param pointe 结束点
 @param color 颜色
 @return layer
 */
+ (CAShapeLayer *)drawLine:(CGPoint)points to:(CGPoint)pointe color:(UIColor *)color;

@end

@interface UIView (Frame)

/** 原点 */
@property (nonatomic) CGPoint origin;
/** 原点x */
@property (nonatomic) CGFloat originX;
/** 原点y */
@property (nonatomic) CGFloat originY;
/** 尺寸 */
@property (nonatomic) CGSize size;
/** 宽度 */
@property (nonatomic) CGFloat width;
/** 高度 */
@property (nonatomic) CGFloat height;
/** 中心点x */
@property (nonatomic) CGFloat centerX;
/** 中心点y */
@property (nonatomic) CGFloat centerY;

/** 左边起点 */
@property (nonatomic) CGFloat left;
/** 顶部起点 */
@property (nonatomic) CGFloat top;
/** 右边终点 */
@property (nonatomic) CGFloat right;
/** 底部终点 */
@property (nonatomic) CGFloat bottom;

/** 仿射变换矩阵tx */
@property (nonatomic) CGFloat ttx;
/** 仿射变换矩阵ty */
@property (nonatomic) CGFloat tty;

@end

