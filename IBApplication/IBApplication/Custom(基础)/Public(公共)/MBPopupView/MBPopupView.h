//
//  MBPopupController.h
//  <https://github.com/snail-z/zhPopupController.git>

//  Created by Bowen on 2020/1/14.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MBPopupMaskType) {
    MBPopupMaskTypeBlackBlur = 0,
    MBPopupMaskTypeWhiteBlur,
    MBPopupMaskTypeWhite,
    MBPopupMaskTypeClear,
    MBPopupMaskTypeBlackTranslucent // default
};

typedef NS_ENUM(NSUInteger, MBPopupLayoutType) {
    MBPopupLayoutTypeTop = 0,
    MBPopupLayoutTypeBottom,
    MBPopupLayoutTypeLeft,
    MBPopupLayoutTypeRight,
    MBPopupLayoutTypeCenter // default
};

typedef NS_ENUM(NSInteger, MBPopupSlideStyle) {
    MBPopupSlideStyleFromTop = 0,
    MBPopupSlideStyleFromBottom,
    MBPopupSlideStyleFromLeft,
    MBPopupSlideStyleFromRight,
    MBPopupSlideStyleShrinkInOut = 4,
    MBPopupSlideStyleShrinkInGrowOut,
    MBPopupSlideStyleFade, // default
};

@interface MBPopupView : NSObject

/// Convenient to initialize and set maske type. (Through the `- init` initialization, maskType is MBPopupMaskTypeBlackTranslucent)
+ (instancetype)popupViewWithMaskType:(MBPopupMaskType)maskType;

/// The `popupView` is the parent view of your custom contentView
@property (nonatomic, strong, readonly) UIView *popupView;

/// Whether contentView is presenting.
@property (nonatomic, assign, readonly) BOOL isPresenting;

/// Set popup view display position. default is MBPopupLayoutTypeCenter
@property (nonatomic, assign) MBPopupLayoutType layoutType;

/// Set popup view slide Style. default is MBPopupSlideStyleFade
@property (nonatomic, assign) MBPopupSlideStyle slideStyle; // When `layoutType = MBPopupLayoutTypeCenter` is vaild.

/// set mask view of transparency, default is 0.5
@property (nonatomic, assign) CGFloat maskAlpha; // When set maskType is MBPopupMaskTypeBlackTranslucent vaild.

/// default is YES. if NO, Mask view will not respond to events.
@property (nonatomic, assign) BOOL dismissOnMaskTouched;

/// default is NO. if YES, Popup view disappear from the opposite direction.
@property (nonatomic, assign) BOOL dismissOppositeDirection; // When `layoutType = MBPopupLayoutTypeCenter` is vaild.

/// Content view whether to allow drag, default is NO
@property (nonatomic, assign) BOOL allowPan; // 1.The view will support dragging when popup view of position is at the center of the screen or at the edge of the screen. 2.The pan gesture will be invalid when the keyboard appears.

/// You can adjust the spacing relative to the keyboard when the keyboard appears. default is 0
@property (nonatomic, assign) CGFloat offsetSpacingOfKeyboard;

/// Use drop animation and set the rotation Angle. if set, Will not support drag.
- (void)dropAnimatedWithRotateAngle:(CGFloat)angle;

/// Block gets called when mask touched.
@property (nonatomic, copy) void (^maskTouched)(MBPopupView *popupView);

/// - Should implement this block before the presenting. 应在present前实现的block ☟
/// Block gets called when contentView will present.
@property (nonatomic, copy) void (^willPresent)(MBPopupView *popupView);

/// Block gets called when contentView did present.
@property (nonatomic, copy) void (^didPresent)(MBPopupView *popupView);

/// Block gets called when contentView will dismiss.
@property (nonatomic, copy) void (^willDismiss)(MBPopupView *popupView);

/// Block gets called when contentView did dismiss.
@property (nonatomic, copy) void (^didDismiss)(MBPopupView *popupView);

/**
 present your content view.
 @param contentView This is the view that you want to appear in popup. / 弹出自定义的contentView
 @param duration Popup animation time. / 弹出动画时长
 @param isSpringAnimated if YES, Will use a spring animation. / 是否使用弹性动画
 @param sView  Displayed on the sView. if nil, Displayed on the window. / 显示在sView上
 @param displayTime The view will disappear after `displayTime` seconds. / 视图将在displayTime后消失
 */
- (void)presentContentView:(nullable UIView *)contentView
                  duration:(NSTimeInterval)duration
            springAnimated:(BOOL)isSpringAnimated
                    inView:(nullable UIView *)sView
               displayTime:(NSTimeInterval)displayTime;

- (void)presentContentView:(nullable UIView *)contentView
                  duration:(NSTimeInterval)duration
            springAnimated:(BOOL)isSpringAnimated
                    inView:(nullable UIView *)sView;

- (void)presentContentView:(nullable UIView *)contentView
                  duration:(NSTimeInterval)duration
            springAnimated:(BOOL)isSpringAnimated;

- (void)presentContentView:(nullable UIView *)contentView displayTime:(NSTimeInterval)displayTime;;

/// duration is 0.25 / springAnimated is NO / show in window
- (void)presentContentView:(nullable UIView *)contentView;

/// dismiss your content view.
- (void)dismissWithDuration:(NSTimeInterval)duration springAnimated:(BOOL)isSpringAnimated;

/// Will use the present parameter values.
- (void)dismiss;

/// fade out of your content view.
- (void)fadeDismiss;

@end

NS_ASSUME_NONNULL_END
