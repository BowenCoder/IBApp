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

- (void)setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset radius:(CGFloat)radius type:(NSString *)type {
    
    [self.layer setShadowColor:color.CGColor];
    [self.layer setShadowOpacity:opacity];
    [self.layer setShadowOffset:offset];
    [self.layer setShadowRadius:radius];
    
    CGSize size = self.bounds.size;
    if ([type isEqualToString:@"Trapezoidal"]){
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(size.width * 0.33f, size.height * 0.66f)];
        [path addLineToPoint:CGPointMake(size.width * 0.66f, size.height * 0.66f)];
        [path addLineToPoint:CGPointMake(size.width * 1.15f, size.height * 1.15f)];
        [path addLineToPoint:CGPointMake(size.width * -0.15f, size.height * 1.15f)];
        self.layer.shadowPath = path.CGPath;
        
    } else if ([type isEqualToString:@"Elliptical"]){
        
        CGRect ovalRect = CGRectMake(0.0f, size.height + 5, size.width - 10, 15);
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
        self.layer.shadowPath = path.CGPath;
        
    } else if ([type isEqualToString:@"Curl"]) { //Curl is not working !!
        
        CGFloat offset = 10.0;
        CGFloat curve = 5.0;
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        CGRect rect = self.bounds;
        CGPoint topLeft         = rect.origin;
        CGPoint bottomLeft     = CGPointMake(0.0, CGRectGetHeight(rect)+offset);
        CGPoint bottomMiddle = CGPointMake(CGRectGetWidth(rect)/2, CGRectGetHeight(rect)-curve);
        CGPoint bottomRight     = CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect)+offset);
        CGPoint topRight     = CGPointMake(CGRectGetWidth(rect), 0.0);
        
        [path moveToPoint:topLeft];
        [path addLineToPoint:bottomLeft];
        [path addQuadCurveToPoint:bottomRight
                     controlPoint:bottomMiddle];
        [path addLineToPoint:topRight];
        [path addLineToPoint:topLeft];
        [path closePath];
        self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        self.layer.borderWidth = 5.0;
        self.layer.shadowOffset = CGSizeMake(0, 3);
        self.layer.shadowOpacity = 0.7;
        self.layer.shouldRasterize = YES;
        self.layer.shadowPath = path.CGPath;
        
    }
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

+ (void)zoom:(UIView *)view duration:(float)duration isIn:(BOOL)isIn {
    
    if (isIn) {
        view.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:duration animations:^{
            view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        view.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:duration animations:^{
            view.transform = CGAffineTransformMakeScale(0, 0);
        } completion:^(BOOL finished) {
            
        }];
    }

}

+ (void)fade:(UIView *)view duration:(float)duration isIn:(BOOL)isIn {
    
    if (isIn) {
        [view setAlpha:0.0];
        [UIView animateWithDuration:duration animations:^{
            [view setAlpha:1.0];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [view setAlpha:1.0];
        [UIView animateWithDuration:duration animations:^{
            [view setAlpha:0.0];
        } completion:^(BOOL finished) {
            
        }];
    }
}

+ (void)move:(UIView *)view duration:(float)duration distance:(CGFloat)distance direction:(UIViewAnimationDirection)direction {
    
    switch (direction) {
        case UIViewAnimationDirectionLeft: {
            [UIView animateWithDuration:duration animations:^{
                view.center = CGPointMake(view.center.x - distance, view.center.y);
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        case UIViewAnimationDirectionRight: {
            [UIView animateWithDuration:duration animations:^{
                view.center = CGPointMake(view.center.x + distance, view.center.y);
            } completion:^(BOOL finished) {
                
            }];
        }
        case UIViewAnimationDirectionTop: {
            [UIView animateWithDuration:duration animations:^{
                view.center = CGPointMake(view.center.x, view.center.y - distance);
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        case UIViewAnimationDirectionBottom: {
            [UIView animateWithDuration:duration animations:^{
                view.center = CGPointMake(view.center.x, view.center.y + distance);
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        default:
            break;
    }
}

+ (void)rotate:(UIView *)view duration:(float)duration angle:(int)angle {
    
    [UIView animateWithDuration:duration animations:^{
        view.layer.transform = CATransform3DRotate(view.layer.transform, M_PI*angle/180.0, 0, 0, 1);
    } completion:^(BOOL finished) {
        
    }];
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
