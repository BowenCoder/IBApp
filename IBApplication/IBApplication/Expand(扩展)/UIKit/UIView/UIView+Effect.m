//
//  UIView+Effect.m
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIView+Effect.h"
#import <objc/runtime.h>

@implementation UIView (Effect)

- (void)setCornerRadius:(CGFloat)radius option:(UIRectCorner)corners {
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:corners
                                           cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setBorderColor:(UIColor *)color width:(CGFloat)width cornerRadius:(CGFloat)radius {
    
    [self.layer setCornerRadius:radius];
    [self.layer setBorderWidth:width];
    [self.layer setBorderColor:color.CGColor];
}

- (void)setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset radius:(CGFloat)radius {
    
    [self.layer setShadowColor:color.CGColor];
    [self.layer setShadowOpacity:opacity];
    [self.layer setShadowOffset:offset];
    [self.layer setShadowRadius:radius];
}

@end

@implementation UIView (Animation)

- (void)shake {
    
    [self _shake:10 direction:1 currentTimes:0 withDelta:5 speed:0.03 shakeDirection:UIViewShakeDirectionHorizontal completion:nil];
}

- (void)_shake:(int)times direction:(int)direction currentTimes:(int)current withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(UIViewShakeDirection)shakeDirection completion:(void (^)(void))completionHandler {
    
    [UIView animateWithDuration:interval animations:^{
        self.layer.affineTransform = (shakeDirection == UIViewShakeDirectionHorizontal) ? CGAffineTransformMakeTranslation(delta * direction, 0) : CGAffineTransformMakeTranslation(0, delta * direction);
    } completion:^(BOOL finished) {
        if(current >= times) {
            [UIView animateWithDuration:interval animations:^{
                self.layer.affineTransform = CGAffineTransformIdentity;
            } completion:^(BOOL finished){
                if (completionHandler != nil) {
                    completionHandler();
                }
            }];
            return;
        }
        [self _shake:(times - 1)
           direction:direction * -1
        currentTimes:current + 1
           withDelta:delta
               speed:interval
      shakeDirection:shakeDirection
          completion:completionHandler];
    }];
}

- (void)addAnimationAtPoint:(CGPoint)point duration:(NSTimeInterval)duration type:(UIViewAnimationType)type color:(UIColor *)color completion:(void (^)(BOOL finished))completion {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGFloat diameter = [self maxBorderDiameterForPoint:point];
    shapeLayer.frame = CGRectMake(floor(point.x - diameter * 0.5), floor(point.y - diameter * 0.5), diameter, diameter);
    shapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0, 0.0, diameter, diameter)].CGPath;
    
    shapeLayer.fillColor = color.CGColor;
    // animate
    CGFloat scale = 1.0 / shapeLayer.frame.size.width;
    NSString *timingFunctionName = kCAMediaTimingFunctionDefault; //inflating ? kCAMediaTimingFunctionDefault : kCAMediaTimingFunctionDefault;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    switch (type) {
        case UIViewAnimationTypeOpen: {
            
            [self.layer addSublayer:shapeLayer];
            animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1.0)];
            break;
        }
        case UIViewAnimationTypeClose: {
            
            [self.layer insertSublayer:shapeLayer atIndex:0];
            animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1.0)];
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
            break;
        }
        default:
            break;
    }
    animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunctionName];
    animation.removedOnCompletion = YES;
    animation.duration = duration;
    shapeLayer.transform = [animation.toValue CATransform3DValue];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [shapeLayer removeFromSuperlayer];
        if (completion) {
            completion(true);
        }
    }];
    [shapeLayer addAnimation:animation forKey:@"shapeBackgroundAnimation"];
    [CATransaction commit];
}

//计算离屏幕的边框最大的距离
- (CGFloat)maxBorderDiameterForPoint:(CGPoint)point {
    
    CGPoint cornerPoints[] = {
        {0.0, 0.0},
        {0.0, self.bounds.size.height},
        {self.bounds.size.width, self.bounds.size.height},
        {self.bounds.size.width, 0.0}
    };
    CGFloat radius = 0.0;
    for (int i = 0; i < 4; i++) {
        CGPoint p = cornerPoints[i];
        CGFloat d = sqrt( pow(p.x - point.x, 2.0) + pow(p.y - point.y, 2.0) );
        if (d > radius) {
            radius = d;
        }
    }
    return radius * 2.0;
}

@end

@implementation UIView (MotionEffect)

static NSString *motionEffectFlag = @"motionEffectFlag";

- (void)setEffectGroup:(UIMotionEffectGroup *)effectGroup {
    
    // 清除掉关联
    objc_setAssociatedObject(self, &motionEffectFlag,
                             nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 建立关联
    objc_setAssociatedObject(self, &motionEffectFlag,
                             effectGroup, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIMotionEffectGroup *)effectGroup {
    // 返回关联
    return objc_getAssociatedObject(self, &motionEffectFlag);
}

- (void)moveAxis:(CGFloat)dx dy:(CGFloat)dy {
    
    if ((dx >= 0) && (dy >= 0)) {
        UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        xAxis.minimumRelativeValue = @(-dx);
        xAxis.maximumRelativeValue = @(dy);
        
        UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        yAxis.minimumRelativeValue = @(-dy);
        yAxis.maximumRelativeValue = @(dy);
        
        // 先移除效果再添加效果
        self.effectGroup.motionEffects = nil;
        [self removeMotionEffect:self.effectGroup];
        self.effectGroup.motionEffects = @[xAxis, yAxis];
        
        // 给view添加效果
        [self addMotionEffect:self.effectGroup];
    }
}

- (void)cancelMotionEffect {
    
    [self removeMotionEffect:self.effectGroup];
}

@end
