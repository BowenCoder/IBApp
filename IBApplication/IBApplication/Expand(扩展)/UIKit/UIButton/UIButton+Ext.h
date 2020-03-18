//
//  UIButton+Ext.h
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Ext)

/**
 *  @brief  设置按钮额外热区
 */
@property (nonatomic, assign) UIEdgeInsets extraAreaInsets;

/**
*  @brief 响应边界扩大倍数
*/
@property (nonatomic, assign) CGFloat hitScale;

/**
 *  @brief  使用颜色设置按钮背景
 *
 *  @param backgroundColor 背景颜色
 *  @param state           按钮状态
 */
- (void)mb_setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

/**
 *  @brief  设置按钮倒计时
 *
 *  @param timeout     秒
 *  @param tittle      秒后面接的文字
 *  @param waitTittle  倒计时结束后显示的文字
 */
-(void)mb_startTime:(NSInteger )timeout title:(NSString *)tittle waitTittle:(NSString *)waitTittle;

@end


@interface UIButton (Indicator)

- (void)mb_showIndicator;

- (void)mb_hideIndicator;

@end

