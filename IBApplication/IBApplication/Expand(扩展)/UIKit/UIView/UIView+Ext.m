//
//  UIView+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIView+Ext.h"
#import "IBPicture.h"

@implementation UIView (Ext)

- (UIView *)topView {
    
    UIView *topSuperView = self.superview;
    
    if (topSuperView == nil) {
        topSuperView = self;
    } else {
        while (topSuperView.superview) {
            topSuperView = topSuperView.superview;
        }
    }
    
    return topSuperView;
}


/**
 *  @brief  找到当前view所在的viewcontroler
 */
- (UIViewController *)viewController {
    
    UIResponder *responder = self.nextResponder;
    do {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    } while (responder);
    return nil;
}

- (void)setBackgroundImage:(UIImage *)image pattern:(BOOL)pattern {
    
    if (image == nil || [image isKindOfClass:[NSNull class]]) {
        return;
    }
    if (pattern) {
        UIImage *img = [IBPicture resizedImage:image size:self.frame.size]; //重绘图片，不然出现平铺效果
        [self setBackgroundColor:[UIColor colorWithPatternImage:img]];
    } else {
        self.layer.contents = (__bridge id _Nullable)(image.CGImage);
        self.layer.contentsScale = [UIScreen mainScreen].scale;
    }
}

///< 移除此view上的所有子视图
- (void)removeAllSubviews {
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

//画线
+ (CAShapeLayer *)drawLine:(CGPoint)points to:(CGPoint)pointe color:(UIColor *)color {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:points];
    [path addLineToPoint:pointe];
    [path closePath];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [color CGColor];
    shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
    shapeLayer.lineWidth = 1;
    return shapeLayer;
}

@end


@implementation UIView (Frame)

- (CGFloat)originX {
    
    return self.frame.origin.x;
}
- (void)setOriginX:(CGFloat)originX {
    
    CGRect frame = self.frame;
    frame.origin.x = originX;
    self.frame = frame;
}

- (CGFloat)originY {
    
    return self.frame.origin.y;
}
- (void)setOriginY:(CGFloat)originY {
    
    CGRect frame = self.frame;
    frame.origin.y = originY;
    self.frame = frame;
}

- (CGFloat)centerX {
    
    return self.center.x;
}
- (void)setCenterX:(CGFloat)centerX {
    
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    
    return self.center.y;
}
- (void)setCenterY:(CGFloat)centerY {
    
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    
    return self.frame.size.width;
}
- (void)setWidth:(CGFloat)width {
    
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    
    return self.frame.size.height;
}
- (void)setHeight:(CGFloat)height {
    
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)origin {
    
    return self.frame.origin;
}
- (void)setOrigin:(CGPoint)origin {
    
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    
    return self.frame.size;
}
- (void)setSize:(CGSize)size {
    
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)left {
    
    return self.frame.origin.x;
}
- (void)setLeft:(CGFloat)left {
    
    self.originX = left;
}

- (CGFloat)top {
    
    return self.frame.origin.y;
}
- (void)setTop:(CGFloat)top {
    
    self.originY = top;
}

- (CGFloat)bottom {
    
    return self.frame.size.height + self.frame.origin.y;
}
-(void)setBottom:(CGFloat)bottom {
    
    CGRect frame = self.frame;
    frame.origin.y = bottom - [self height];
    self.frame = frame;
}

- (CGFloat)right {
    
    return self.frame.size.width + self.frame.origin.x;
}
- (void)setRight:(CGFloat)right {
    
    CGRect frame = self.frame;
    frame.origin.x = right - [self width];
    self.frame = frame;
}

- (CGFloat)ttx {
    
    return self.transform.tx;
}
- (void)setTtx:(CGFloat)ttx {
    
    CGAffineTransform transform=self.transform;
    transform.tx=ttx;
    self.transform=transform;
}


- (CGFloat)tty {
    
    return self.transform.ty;
}
- (void)setTty:(CGFloat)tty {
    
    CGAffineTransform transform=self.transform;
    transform.ty=tty;
    self.transform=transform;
}

@end

