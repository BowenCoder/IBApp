//
//  UITextField+Ext.h
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Ext)

/**
 设置光标颜色
 
 @param color 光标颜色
 */
- (void)mb_setCursorColor:(UIColor *)color;

/**
 设置plcaceholder样式
 
 @param placeholder 文本
 @param color 颜色
 @param font 字体
 */
- (void)mb_setPlaceholder:(NSString *)placeholder color:(UIColor *)color font:(CGFloat)font;

/**
 设置右边button
 
 @param title 标题
 @param titleColor 标题颜色
 @param font 字体大小
 @param width 按钮宽度
 @param target 响应对象
 @param selector 响应方法
 @param backgroundColor 背景颜色
 @return button
 */
- (UIButton *)mb_rightButtonTitle:(NSString *)title
                       titleColor:(UIColor *)titleColor
                        titleFont:(CGFloat)font
                            width:(CGFloat)width
                           target:(id)target
                         selector:(SEL)selector
                  backgroundColor:(UIColor *)backgroundColor;

/**
 设置左边label样式
 
 @param title 标题
 @param titleColor 标题颜色
 @param font 字体大小
 @param width label宽度
 @param backgroundColor 背景颜色
 */
- (void)mb_leftLabelTitle:(NSString *)title
               titleColor:(UIColor *)titleColor
                titleFont:(CGFloat)font
                    width:(CGFloat)width
          backgroundColor:(UIColor *)backgroundColor;

@end
