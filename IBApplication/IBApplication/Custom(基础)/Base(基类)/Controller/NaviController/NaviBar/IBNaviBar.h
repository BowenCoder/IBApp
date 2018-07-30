//
//  IBNaviBar.h
//  IBApplication
//
//  Created by Bowen on 2018/7/8.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBNaviConfig.h"

@interface IBNaviBar : UINavigationBar

#pragma mark - 全局外观

/** 全局设置背景颜色 */
@property (nonatomic, strong) UIColor *globalBarColor;

/** 全局设置控件颜色 */
@property (nonatomic, strong) UIColor *globalTintColor;

/** 全局设置背景图片 */
@property (nonatomic, strong) UIImage *globalBgImage;

/** 全局设置透明 */
@property (nonatomic, assign) BOOL lucencyBar;

/** 全局隐藏黑线 */
@property (nonatomic, assign) BOOL hiddenLine;

/** 设置导航栏标题颜色、大小 */
+ (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)fontSize;

/** 设置按钮的颜色、大小(自定义按钮无效) */
+ (void)setItemTitleColor:(UIColor *)color fontSize:(CGFloat)fontSize;


- (UIView *)backgroundView;
- (void)updateBarStyle:(UIBarStyle)barStyle tintColor:(UIColor *)tintColor;
- (void)updateNaviBarConfig:(IBNaviConfig *)config;
- (void)updateBackgroundAlpha:(CGFloat)alpha;

//- (void)setTranslationY:(CGFloat)translationY;
//- (void)resetTranslation;


@end
