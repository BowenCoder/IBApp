//
//  MBProgressHUD+Ext.h
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBProgressHUD.h"

//默认持续显示时间(x秒后消失)
UIKIT_EXTERN CGFloat const delayTime;

typedef NS_ENUM(NSInteger, MBPosition) {
    MBPositionTop,//上面
    MBPositionCenter,//中间
    MBPositionBottom,//下面
};

typedef NS_ENUM(NSInteger, MBProgressBarMode) {
    MBProgressModeDeterminate,
    MBProgressModeAnnularDeterminate,
    MBProgressModeHorizontalBar,
};

@interface MBProgressHUD (Ext)

#pragma mark - Toast

/** 显示成功 */
+ (void)showSuccess:(UIView *)superview title:(NSString *)title;

/** 显示失败 */
+ (void)showError:(UIView *)superview title:(NSString *)title;

/** 纯加载图 */
+ (MBProgressHUD *)showLoading:(UIView *)superview;

/** 加载图 + 文字 */
+ (MBProgressHUD *)showLoading:(UIView *)superview text:(NSString *)text;

/** 加载图 + 文字 + 蒙版 */
+ (MBProgressHUD *)showLoading:(UIView *)superview text:(NSString *)text background:(UIColor *)color;

/** 自定义加载图 + 文字 */
+ (MBProgressHUD *)showCustom:(UIView *)superview view:(UIView *)view text:(NSString *)text;

/** gif + 文字 */
+ (MBProgressHUD *)showLoadingGif:(UIView *)superview gif:(NSData *)data text:(NSString *)text;

/** 纯文字 */
+ (void)showText:(UIView *)superview title:(NSString *)title position:(MBPosition)position;

/** 纯文字标题 + 详情 */
+ (void)showText:(UIView *)superview title:(NSString *)title detail:(NSString *)detail position:(MBPosition)position;

/** 进度条 + 文字 + 详情 */
+ (MBProgressHUD *)showProgress:(UIView *)superview title:(NSString *)title detail:(NSString *)detail progress:(void(^)(MBProgressHUD *hud))callback mode:(MBProgressBarMode)mode;

/** 隐藏ProgressView */
+ (void)hideHUDForView:(UIView *)view;

/** 隐藏（从window）*/
+ (void)hideHUD;

#pragma mark - Loading

+ (void)showBallLoadingView:(UIView *)superview;
+ (void)hideBallLoadingView:(UIView *)superview;

+ (void)showCircleLoadingView:(UIView *)superview;
+ (void)hideCircleLoadingView:(UIView *)superview;

+ (void)showTriangleLoadingView:(UIView *)superview;
+ (void)hideTriangleLoadingView:(UIView *)superview;

+ (void)showSwapLoadingView:(UIView *)superview;
+ (void)hideSwapLoadingView:(UIView *)superview;


@end


