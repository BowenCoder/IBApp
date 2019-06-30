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

- (void)mb_setCornerRadius:(CGFloat)radius option:(UIRectCorner)corners {
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:corners
                                           cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)mb_setBorderColor:(UIColor *)color width:(CGFloat)width cornerRadius:(CGFloat)radius {
    
    [self.layer setCornerRadius:radius];
    [self.layer setBorderWidth:width];
    [self.layer setBorderColor:color.CGColor];
}

- (void)mb_setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset radius:(CGFloat)radius type:(NSString *)type {
    
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

static NSString *motionEffectFlag = @"motionEffectFlag";

@implementation UIView (MotionEffect)

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

- (void)mb_moveAxis:(CGFloat)dx dy:(CGFloat)dy {
    
    if ((dx >= 0) && (dy >= 0)) {
        UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        xAxis.minimumRelativeValue = @(-dx);
        xAxis.maximumRelativeValue = @(dy);
        
        UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        yAxis.minimumRelativeValue = @(-dy);
        yAxis.maximumRelativeValue = @(dy);
        
        // 先移除效果再添加效果
        UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
        motionEffectGroup.motionEffects = @[xAxis, yAxis];

        self.effectGroup.motionEffects = nil;
        [self removeMotionEffect:self.effectGroup];
        self.effectGroup.motionEffects = @[xAxis, yAxis];
        
        // 给view添加效果
        [self addMotionEffect:self.effectGroup];
    }
}

- (void)mb_cancelMotionEffect {
    
    [self removeMotionEffect:self.effectGroup];
}

@end
