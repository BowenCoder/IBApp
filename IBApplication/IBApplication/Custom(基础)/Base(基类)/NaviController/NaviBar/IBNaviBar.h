//
//  IBNaviBar.h
//  IBApplication
//
//  Created by Bowen on 2018/7/8.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IBNaviBar : UINavigationBar

/** 全局设置背景颜色 */
@property (nonatomic, strong) UIColor *globalBarTintColor;

/** 全局设置控件颜色 */
@property (nonatomic, strong) UIColor *globalTintColor;

/** 全局设置透明 */
@property (nonatomic, assign) BOOL lucencyBar;

/** 全局隐藏黑线 */
- (void)hiddenBarBottomLine:(BOOL)hidden;

/** 设置导航栏标题颜色、大小 */
+ (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)fontSize;

/** 设置按钮的颜色、大小(自定义按钮无效) */
+ (void)setItemTitleColor:(UIColor *)color fontSize:(CGFloat)fontSize;

@end
