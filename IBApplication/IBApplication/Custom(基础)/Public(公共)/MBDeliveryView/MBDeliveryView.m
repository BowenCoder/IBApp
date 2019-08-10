//
//  MBDeliveryView.m
//  IBApplication
//
//  Created by Bowen on 2019/8/10.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBDeliveryView.h"

@implementation MBDeliveryView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    // 1.判断下自己能否接收事件
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01) return nil;
    
    // 2.判断下点在不在当前控件上
    if ([self pointInside:point withEvent:event] == NO) return nil; // 点不在当前控件
    
    // 3.从前往后遍历自己的子控件
    int count = (int)self.subviews.count;
    for (int i = 0; i <= count-1; i++) {
        // 获取子控件
        UIView *childView = self.subviews[i];
        
        // 把当前坐标系上的点转换成子控件上的点
        CGPoint childPoint =  [self convertPoint:point toView:childView];
        
        UIView *fitView = [childView hitTest:childPoint withEvent:event];
        
        if (fitView) {
            return fitView;
        }
    }
    // 4.如果没有比自己合适的子控件,最合适的view就是自己
    return self;
}


@end
