//
//  IBPopupControllerTransitioningSlideVertical.m
//  IBPopup
//
//  Created by Bowen on 2018/8/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBPopupControllerTransitioningSlideVertical.h"

@implementation IBPopupControllerTransitioningSlideVertical

- (NSTimeInterval)popupControllerTransitionDuration:(IBPopupControllerTransitioningContext *)context
{
    return context.action == IBPopupControllerTransitioningActionPresent ? 0.5 : 0.35;
}

- (void)popupControllerAnimateTransition:(IBPopupControllerTransitioningContext *)context completion:(void (^)(void))completion
{
    UIView *containerView = context.containerView;
    if (context.action == IBPopupControllerTransitioningActionPresent) {
        containerView.transform = CGAffineTransformMakeTranslation(0, containerView.superview.bounds.size.height - containerView.frame.origin.y);
        
        [UIView animateWithDuration:[self popupControllerTransitionDuration:context] delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            context.containerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
    else {
        CGAffineTransform lastTransform = containerView.transform;
        containerView.transform = CGAffineTransformIdentity;
        CGFloat originY = containerView.frame.origin.y;
        containerView.transform = lastTransform;

        [UIView animateWithDuration:[self popupControllerTransitionDuration:context] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            containerView.transform = CGAffineTransformMakeTranslation(0, containerView.superview.bounds.size.height - originY + containerView.frame.size.height);
        } completion:^(BOOL finished) {
            containerView.transform = CGAffineTransformIdentity;
            completion();
        }];
    }
}

@end
