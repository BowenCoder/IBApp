//
//  MBCommonViewController.h
//  IBApplication
//
//  Created by Bowen on 2020/4/2.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBCommonViewController : UIViewController

/** 反向传值使用 */
@property (nonatomic, copy) void (^callback)(id);

/** 正向传值使用 */
@property (nonatomic, copy) NSDictionary *params;

/** 修改当前界面要支持的横竖屏方向 */
@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;

/** 是否隐藏状态栏 */
@property (nonatomic, assign) BOOL isStatusBarHidden;

/** 状态栏样式 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/** 是否隐藏iPhoneX底部黑色横条 */
@property (nonatomic, assign) BOOL isHomeIndicatorAutoHidden;

/** 是否禁止左滑返回 */
@property (nonatomic, assign) BOOL isForbidSwipeLeftBack;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 *  初始化时调用的方法，会在两个 NS_DESIGNATED_INITIALIZER 方法中被调用，所以子类如果需要同时支持两个 NS_DESIGNATED_INITIALIZER 方法，则建议把初始化时要做的事情放到这个方法里。否则仅需重写要支持的那个 NS_DESIGNATED_INITIALIZER 方法即可。
 */
- (void)onInit NS_REQUIRES_SUPER;

/**
 viewDidLoad中调用，在setupData之前
*/
- (void)setupUI NS_REQUIRES_SUPER;

/**
 viewDidLoad中调用，在setupUI之后
*/
- (void)setupData NS_REQUIRES_SUPER;

/**
 设置背景图片
 */
- (void)setBackgroundImage:(UIImage *)image;

/**
 设置导航栏右边按钮
 
 @param title 标题
 @param color 标题颜色
 @param name 图片名字
 @param action 方法
 @return UIBarButtonItem
 */
- (UIBarButtonItem *)rightBarItemWithTitle:(NSString *)title titleColor:(UIColor *)color imageName:(NSString *)name action:(SEL)action;

/**
 设置导航栏左边按钮
 
 @param title 标题
 @param color 标题颜色
 @param name 图片名字
 @param action 方法
 @return UIBarButtonItem
 */
- (UIBarButtonItem *)leftBarItemWithTitle:(NSString *)title titleColor:(UIColor *)color imageName:(NSString *)name action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
