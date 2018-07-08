//
//  IBController.h
//  IBApplication
//
//  Created by Bowen on 2018/7/4.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBHTTPClient.h"

@interface IBController : UIViewController

/** 反向传值使用 */
@property (nonatomic, copy) void (^callback)(id);

/**
 UI初始化之前运行
 */
- (void)onInit;

/**
 UI初始化
 */
- (void)initUI;

/**
 UI初始化之后运行
 */
- (void)initData;

/**
 清除缓存
 */
- (void)clearCache;

/**
 设置背景图片
 */
- (void)setBackgroundImage:(UIImage *)image;

/**
 设置导航栏右边按钮
 
 @param title 标题
 @param color 标题颜色
 @param name 图片名字
 @return UIBarButtonItem
 */
- (UIBarButtonItem *)rightBarItemWithTitle:(NSString *)title titleColor:(UIColor *)color imageName:(NSString *)name;

/**
 设置导航栏左边按钮
 
 @param title 标题
 @param color 标题颜色
 @param name 图片名字
 @return UIBarButtonItem
 */
- (UIBarButtonItem *)leftBarItemWithTitle:(NSString *)title titleColor:(UIColor *)color imageName:(NSString *)name;

/**
 右边按钮点击事件
 
 @param button 按钮
 */
- (void)rightBarItemClick:(UIButton *)button;

/**
 左边按钮点击事件
 
 @param button 按钮
 */
- (void)leftBarItemClick:(UIButton *)button;


@end
