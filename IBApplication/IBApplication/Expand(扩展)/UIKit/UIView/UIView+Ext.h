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
- (UIView *)mb_topView;

/**
 移除所有视图
 */
- (void)mb_removeAllSubviews;

/**
 找到当前视图所在的控制器

 @return viewController
 */
- (UIViewController *)mb_viewController;

/// 找到第一响应者
- (id)mb_findFirstResponder;

/**
 设置背景图片

 @param image 图片
 @param pattern YES,占用内存低，但是稍微模糊；NO，占用内存高，但是高清
 */
- (void)mb_setBackgroundImage:(UIImage *)image pattern:(BOOL)pattern;

/**
 画线

 @param points 起始点
 @param pointe 结束点
 @param color 颜色
 @return layer
 */
+ (CAShapeLayer *)mb_drawLine:(CGPoint)points to:(CGPoint)pointe color:(UIColor *)color;

@end

@interface UIView (Frame)

/** 原点 */
@property (nonatomic) CGPoint origin;
/** 尺寸 */
@property (nonatomic) CGSize size;
/** 原点x */
@property (nonatomic) CGFloat originX;
/** 原点y */
@property (nonatomic) CGFloat originY;
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

