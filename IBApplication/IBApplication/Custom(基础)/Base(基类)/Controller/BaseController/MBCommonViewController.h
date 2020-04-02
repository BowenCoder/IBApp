//
//  MBCommonViewController.h
//  IBApplication
//
//  Created by Bowen on 2020/4/2.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBEmptyView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBCommonViewController : UIViewController {
    MBEmptyView *_emptyView;
}

/** 反向传值使用 */
@property (nonatomic, copy) void (^callback)(id);

/** 正向传值使用 */
@property (nonatomic, copy) NSDictionary *params;

/** 设置背景图片 */
@property (nonatomic, strong) UIImage *backgroundImage;

/** 控制横竖屏方向 */
@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;

/** 是否隐藏状态栏 */
@property (nonatomic, assign) BOOL isStatusBarHidden;

/** 控制状态栏样式 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/** 控制iPhoneX底部黑色横条 */
@property (nonatomic, assign) BOOL isHomeIndicatorAutoHidden;

/** 是否禁止左滑返回 */
@property (nonatomic, assign) BOOL isForbidSwipeLeftBack;

/** 空视图控件，支持显示提示文字、loading、操作按钮 */
@property (nonatomic, strong) MBEmptyView *emptyView;

/** 当前空视图是否显示 */
@property (assign, readonly, getter = isEmptyViewShowing) BOOL emptyViewShowing;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

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
 *  显示emptyView
 *  emptyView 的以下系列接口可以按需进行重写
 *
 *  @see QMUIEmptyView
 */
- (void)showEmptyView;

/**
 *  显示loading的emptyView
 */
- (void)showEmptyViewWithLoading;

/**
 *  显示带text、detailText、button的emptyView
 */
- (void)showEmptyViewWithText:(nullable NSString *)text
                   detailText:(nullable NSString *)detailText
                  buttonTitle:(nullable NSString *)buttonTitle
                 buttonAction:(nullable SEL)action;

/**
 *  显示带image、text、detailText、button的emptyView
 */
- (void)showEmptyViewWithImage:(nullable UIImage *)image
                          text:(nullable NSString *)text
                    detailText:(nullable NSString *)detailText
                   buttonTitle:(nullable NSString *)buttonTitle
                  buttonAction:(nullable SEL)action;

/**
 *  显示带loading、image、text、detailText、button的emptyView
 */
- (void)showEmptyViewWithLoading:(BOOL)showLoading
                           image:(nullable UIImage *)image
                            text:(nullable NSString *)text
                      detailText:(nullable NSString *)detailText
                     buttonTitle:(nullable NSString *)buttonTitle
                    buttonAction:(nullable SEL)action;

/**
 *  隐藏emptyView
 */
- (void)hideEmptyView;

/**
 *  布局emptyView，如果emptyView没有被初始化或者没被添加到界面上，则直接忽略掉。
 *
 *  如果有特殊的情况，子类可以重写，实现自己的样式
 *
 *  @return YES表示成功进行一次布局，NO表示本次调用并没有进行布局操作（例如emptyView还没被初始化）
 */
- (BOOL)layoutEmptyView;

/**
 设置导航栏右边按钮
 
 @param title 标题
 @param color 标题颜色
 @param name 图片名字
 @param action 方法
 @return UIBarButtonItem
 */
- (UIBarButtonItem *)rightBarItemWithTitle:(NSString *)title
                                titleColor:(UIColor *)color
                                 imageName:(NSString *)name
                                    action:(SEL)action;

/**
 设置导航栏左边按钮
 
 @param title 标题
 @param color 标题颜色
 @param name 图片名字
 @param action 方法
 @return UIBarButtonItem
 */
- (UIBarButtonItem *)leftBarItemWithTitle:(NSString *)title
                               titleColor:(UIColor *)color
                                imageName:(NSString *)name
                                   action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
