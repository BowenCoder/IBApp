//
//  IBPopupControllerTransitioningFade.m
//  IBPopup
//
//  Created by Bowen on 2018/8/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBPopupControllerTransitioningFade.h"

@implementation IBPopupControllerTransitioningFade

- (NSTimeInterval)popupControllerTransitionDuration:(IBPopupControllerTransitioningContext *)context
{
    return context.action == IBPopupControllerTransitioningActionPresent ? 0.25 : 0.2;
}

- (void)popupControllerAnimateTransition:(IBPopupControllerTransitioningContext *)context completion:(void (^)(void))completion
{
    UIView *containerView = context.containerView;
    if (context.action == IBPopupControllerTransitioningActionPresent) {
        containerView.alpha = 0;
        containerView.transform = CGAffineTransformMakeScale(1.05, 1.05);
        
        [UIView animateWithDuration:[self popupControllerTransitionDuration:context] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            containerView.alpha = 1;
            containerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
    else {
        [UIView animateWithDuration:[self popupControllerTransitionDuration:context] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            containerView.alpha = 0;
        } completion:^(BOOL finished) {
            containerView.alpha = 1;
            completion();
        }];
    }
}

@end
