//
//  UIPopupManager.h
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @brief 弹出manager时的动画起始方向
 */
typedef NS_ENUM(NSInteger, UIPopupAnimation) {
    UIPopupAnimationNone,           //! 无
    UIPopupAnimationTopLeft,        //! 左上角
    UIPopupAnimationTopCenter,      //! 顶部中心
    UIPopupAnimationTopRight,       //! 右上角
    UIPopupAnimationCenterLeft,     //! 左中央
    UIPopupAnimationCenter,         //! 正中间
    UIPopupAnimationCenterRight,    //! 右中央
    UIPopupAnimationBottomLeft,     //! 左下角
    UIPopupAnimationBottomCenter,   //! 底部中心
    UIPopupAnimationBottomRight,    //! 右下角
};

/*!
 @brief 负责popUp的manager
 */
@interface UIPopupManager : NSObject

/*!
 @brief 是否支持点击界面背景时界面消失（默认为YES）
 */
@property (nonatomic, assign) BOOL supportDismissForClickBackground;

/*!
 @brief 是否支持点击界面亮度渐变（默认为YES）
 */
@property (nonatomic, assign) BOOL supportAnimateAlpha;// Alpha渐变，默认支持

/*!
 @brief 添加需要弹出的子控件（无动画效果）
 @param customView 需要弹出的子控件 customView支持简单的frame布局（横、竖屏布局都支持）
 */
- (void)addCustomView:(UIView *)customView;// 无动画

/*!
 @brief 添加需要弹出的子控件
 @param customView 需要弹出的子控件 customView支持简单的frame布局（横、竖屏布局都支持）
 @param animationType 动画类型
 @param duration 动画持续时间
 */
- (void)addCustomView:(UIView *)customView
                 type:(UIPopupAnimation)animationType
             duration:(double)duration;


/*!
 @brief 被移除时的回调
 */
@property (nonatomic, copy) dispatch_block_t dismissBlock;

@end
