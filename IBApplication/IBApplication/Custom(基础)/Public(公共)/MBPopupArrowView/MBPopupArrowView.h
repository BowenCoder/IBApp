//
//  MBPopoverView.h
//  IBApplication
//
//  Created by Bowen on 2018/9/20.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBPopupArrowView;

typedef NS_ENUM(NSUInteger, MBPopupArrowDirection) {
    MBPopupArrowDirectionAny,
    MBPopupArrowDirectionTop,
    MBPopupArrowDirectionLeft,
    MBPopupArrowDirectionBottom,
    MBPopupArrowDirectionRight
};

typedef NS_ENUM(NSUInteger, MBPopupArrowStyle) {
    MBPopupArrowStyleDefault,
    MBPopupArrowStyleLight
};

typedef NS_ENUM(NSInteger, MBPopupArrowPriority) {
    MBPopupArrowPriorityHorizontal,
    MBPopupArrowPriorityVertical
};

@interface MBPopupArrowView : UIView

@property (nonatomic, assign) CGPoint offsets UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat arrowAngle UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat arrowSize UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat arrowCornerRadius UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) MBPopupArrowDirection preferredArrowDirection UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) MBPopupArrowStyle translucentStyle UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) MBPopupArrowPriority priority UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *backgroundDrawingColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat preferredWidth UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) BOOL translucent;
@property (nonatomic, assign) BOOL dimBackground;
@property (nonatomic, assign) BOOL hideOnTouch;

@property (nonatomic, strong) UIView *contentView;

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated completion:(dispatch_block_t)completion;
- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration;

- (void)showFromView:(UIView *)view inView:(UIView *)aView animated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)showFromView:(UIView *)view inView:(UIView *)aView animated:(BOOL)animated completion:(dispatch_block_t)completion;

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(dispatch_block_t)completion;

+ (void)hideVisiblePopoverViewsAnimated:(BOOL)animated fromView:(UIView *)popoverView;

- (void)registerScrollView:(UIScrollView *)scrollView;
- (void)unregisterScrollView;

@end









