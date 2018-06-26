//
//  UIButton+Ext.h
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 图片和文字布局类型
 */
typedef NS_ENUM(NSUInteger, UIButtonEdgeInsetsStyle) {
    UIButtonEdgeInsetsStyleTop, // image在上，label在下
    UIButtonEdgeInsetsStyleLeft, // image在左，label在右
    UIButtonEdgeInsetsStyleBottom, // image在下，label在上
    UIButtonEdgeInsetsStyleRight // image在右，label在左
};

@interface UIButton (Ext)

/**
 *  @brief  设置按钮额外热区
 */
@property (nonatomic, assign) UIEdgeInsets extraAreaInsets;

/**
 *  @brief  使用颜色设置按钮背景
 *
 *  @param backgroundColor 背景颜色
 *  @param state           按钮状态
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

/**
 *  @brief  设置按钮倒计时
 *
 *  @param timeout     秒
 *  @param tittle      秒后面接的文字
 *  @param waitTittle  倒计时结束后显示的文字
 */
-(void)startTime:(NSInteger )timeout title:(NSString *)tittle waitTittle:(NSString *)waitTittle;

/**
 *  @brief  调整图片文字布局
 *
 *  @param style 布局类型
 *  @param space 图片和文字的间隙
 */
- (void)layoutButtonEdgeInsetsStyle:(UIButtonEdgeInsetsStyle)style
                              space:(CGFloat)space;

@end


@interface UIButton (Indicator)

/**
 This method will show the activity indicator in place of the button text.
 */
- (void) showIndicator;

/**
 This method will remove the indicator and put thebutton text back in place.
 */
- (void) hideIndicator;

@end

