//
//  UIView+Ext.h
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Effect.h"

/**
当某个 UIView 在 setFrame: 时高度传这个值，则会自动将 sizeThatFits 算出的高度设置为当前 view 的高度，相当于以下这段代码的简化：
@code
// 以前这么写
CGSize size = [view sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
view.frame = CGRectMake(x, y, width, size.height);

// 现在可以这么写：
view.frame = CGRectMake(x, y, width, QMUIViewSelfSizingHeight);
@endcode
*/
extern const CGFloat MBUIViewSelfSizingHeight;

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

/**
 屏幕内可视区域
 */
@property (nonatomic) CGRect visibleRect;

/**
 将要设置的 frame 用 CGRectApplyAffineTransformWithAnchorPoint 处理后再设置
 */
@property (nonatomic) CGRect frameApplyTransform;

/**
 在 iOS 11 及之后的版本，此属性将返回系统已有的 self.safeAreaInsets。在之前的版本此属性返回 UIEdgeInsetsZero
 */
@property(nonatomic, assign, readonly) UIEdgeInsets safeAreaEdgeInsets;

@end

