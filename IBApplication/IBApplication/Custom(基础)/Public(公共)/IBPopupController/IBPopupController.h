//
//  IBPopupController.h
//  IBPopup
//
//  Created by Bowen on 2018/8/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBPopupNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, IBPopupControllerTransitioningAction) {
    IBPopupControllerTransitioningActionPresent,
    IBPopupControllerTransitioningActionDismiss
};

@interface IBPopupControllerTransitioningContext : NSObject

/**
 Indicating the transitioning is a "present" or "dismiss" action.
 */
@property (nonatomic, assign, readonly) IBPopupControllerTransitioningAction action;

/**
 Container view of popup controller.
 */
@property (nonatomic, strong, readonly) UIView *containerView;

@end

@protocol IBPopupControllerTransitioning <NSObject>

/**
 Return duration of transitioning, it will be used to animate transitioning of background view.
 */
- (NSTimeInterval)popupControllerTransitionDuration:(IBPopupControllerTransitioningContext *)context;

/**
 Animate transitioning the container view of popup controller. "completion" need to be called after transitioning is finished.
 Initially "containerView" will be placed at the final position with transform = CGAffineTransformIdentity if it's presenting.
 */
- (void)popupControllerAnimateTransition:(IBPopupControllerTransitioningContext *)context completion:(void(^)(void))completion;

@end

typedef NS_ENUM(NSUInteger, IBPopupStyle) {
    /**
     Popup will be vertically and horizontally centered.
     */
    IBPopupStyleFormSheet,
    /**
     Popup will be horizontally centered and sticked to bottom.
     */
    IBPopupStyleBottomSheet
};

typedef NS_ENUM(NSUInteger, IBPopupTransitionStyle) {
    /**
     Slide from bottom to center.
     */
    IBPopupTransitionStyleSlideVertical,
    /**
     Fade-in in center from transparent to opaque.
     */
    IBPopupTransitionStyleFade,
    /**
     Custom transitioning by providing an implementation of IBPopupControllerTransitioning protocol
     */
    IBPopupTransitionStyleCustom
};

@interface IBPopupController : NSObject

/**
 Style decides the final position of a popup.
 @see IBPopupStyle
 */
@property (nonatomic, assign) IBPopupStyle style;

/**
 Transition style used in presenting and dismissing the popup.
 @see IBPopupTransitionStyle
 */
@property (nonatomic, assign) IBPopupTransitionStyle transitionStyle;

/**
 Custom defined transitioning, it will be used if "transitionStyle" is set to IBPopupTransitionStyleCustom
 */
@property (nullable, nonatomic, weak) id<IBPopupControllerTransitioning> transitioning;

/**
 Corner radius of the container view.
 */
@property (nonatomic, assign) CGFloat cornerRadius DEPRECATED_MSG_ATTRIBUTE("Use containerView.layer.cornerRadius instead");

/**
 Hidden status of navigation bar of popup.
 */
@property (nonatomic, assign) BOOL navigationBarHidden;

/**
 Hides close button if there is only one view controller in the view controllers stack.
 */
@property (nonatomic, assign) BOOL hidesCloseButton;

/**
 Navigation bar of popup.
 @see IBPopupNavigationBar
 */
@property (nonatomic, strong, readonly) IBPopupNavigationBar *navigationBar;

/**
 Background view which is between popup and the view presenting popup.
 By default it's a UIView with background color [UIColor colorWithWhite:0 alpha:0.5].
 */
@property (nullable, nonatomic, strong) UIView *backgroundView;

/**
 Container view which is containing the navigation bar and content of top most view controller.
 By default its background color is set to white and clipsToBounds is set to YES.
 */
@property (nonatomic, strong, readonly) UIView *containerView;

/**
 *  The top view controller in the popup's controller stack.
 */
@property (nullable, nonatomic, strong, readonly) UIViewController *topViewController;

/**
 Indicates if the popup is current presented.
 */
@property (nonatomic, assign, readonly) BOOL presented;

/**
 Init the popup with root view controller.
 */
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

/**
 Present the popup with transition style on a given view controller.
 @see transitionStyle
 */
- (void)presentInViewController:(UIViewController *)viewController;

/**
 Present the popup with transition style on a given view controller.
 Completion block will be called after the presenting transition is finished.
 @see transitionStyle
 */
- (void)presentInViewController:(UIViewController *)viewController completion:(nullable void (^)(void))completion;

/**
 Dismiss the popup with transition style.
 @see transitionStyle
 */
- (void)dismiss;

/**
 Dismiss the popup with transition style.
 Completion block will be called after dismissing transition is finished.
 @see transitionStyle
 */
- (void)dismissWithCompletion:(nullable void (^)(void))completion;

/**
 Push a view controller into view controllers stack with animated flag.
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 Pop the top most view controller out of view controllers stack with animated flag.
 */
- (void)popViewControllerAnimated:(BOOL)animated;


/**
 Pops all view controllers from the stack until it reaches the root view controller

 @param animated YES if animated
 */
- (void)popToRootViewControllerAnimated:(BOOL)animated;

/**
 Set hidden status of navigation bar with animated flag.
 @see navigationBarHidden
 */
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
