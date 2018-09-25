//
//  IBPopoverView.h
//  IBApplication
//
//  Created by Bowen on 2018/9/20.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IBPopoverView;

typedef void(^IBPopoverViewConfiguration)(IBPopoverView *popoverView);

typedef NS_ENUM(NSUInteger, IBPopoverArrowDirection) {
    IBPopoverArrowDirectionAny,
    IBPopoverArrowDirectionTop,
    IBPopoverArrowDirectionLeft,
    IBPopoverArrowDirectionBottom,
    IBPopoverArrowDirectionRight
};

typedef NS_ENUM(NSUInteger, IBPopoverTranslucentStyle) {
    IBPopoverTranslucentDefault,
    IBPopoverTranslucentLight
};

typedef NS_ENUM(NSInteger, IBPopoverPriorityDirection) {
    IBPopoverPriorityHorizontal,
    IBPopoverPriorityVertical
};

@interface IBPopoverView : UIView

@property (nonatomic, assign) CGPoint offsets UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat arrowAngle UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat arrowSize UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat arrowCornerRadius UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) IBPopoverArrowDirection preferredArrowDirection UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) IBPopoverTranslucentStyle translucentStyle UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) IBPopoverPriorityDirection priority UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *backgroundDrawingColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat preferredWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat padding UI_APPEARANCE_SELECTOR;

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

@interface UIView (IBPopover)

@property (nonatomic, readonly) NSUInteger referenceCount;
@property (nonatomic, readonly) NSMutableArray *registeredPopoverViews;

- (void)registerPopoverView:(IBPopoverView *)popoverView;
- (void)unregisterPopoverView:(IBPopoverView *)popoverView;

@end










