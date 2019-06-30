//
//  MBGestureView.m
//  IBApplication
//
//  Created by Bowen on 2019/7/1.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBGestureView.h"

@implementation MBGestureView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if ([view isKindOfClass:[MBGestureView class]]) {
        MBGestureView *gestureView = (MBGestureView *)view;
        if (!gestureView.canHandleEvent) {
            return nil;
        }
    }
    return view;
}

@end
