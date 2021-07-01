//
//  UIView+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIView+Ext.h"
#import "IBImage.h"
#import "UIMacros.h"
#import "RSSwizzle.h"

const CGFloat MBUIViewSelfSizingHeight = INFINITY;

@implementation UIView (Ext)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RSSwizzleInstanceMethod([UIView class],
                                @selector(setFrame:),
                                RSSWReturnType(void),
                                RSSWArguments(CGRect frame),
                                RSSWReplacement(
        {
            // MBUIViewSelfSizingHeight 的功能
            if (CGRectGetWidth(frame) > 0 && isinf(CGRectGetHeight(frame))) {
                CGFloat height = flat([self sizeThatFits:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX)].height);
                frame = CGRectSetHeight(frame, height);
            }
            
            // 对非法的 frame，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
            if (CGRectIsNaN(frame)) {
                NSLog(@"%@ setFrame:%@，参数包含 NaN，已被拦截并处理为 0。%@", self, NSStringFromCGRect(frame), [NSThread callStackSymbols]);
                frame = CGRectSafeValue(frame);
            }
            
            return RSSWCallOriginal(frame);
        }), RSSwizzleModeAlways, "app.view.setFrame.inf");
    });
}

- (UIView *)mb_topView {
    
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

///< 移除此view上的所有子视图
- (void)mb_removeAllSubviews {
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

/**
 *  @brief  找到当前view所在的viewcontroler
 */
- (UIViewController *)mb_viewController {
    
    UIResponder *responder = self.nextResponder;
    do {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    } while (responder);
    return nil;
}

- (id)mb_findFirstResponder {
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        id responder = [subView mb_findFirstResponder];
        if (responder) return responder;
    }
    return nil;
}


- (void)mb_setBackgroundImage:(UIImage *)image pattern:(BOOL)pattern {
    
    if (image == nil || [image isKindOfClass:[NSNull class]]) {
        return;
    }
    if (pattern) {
        UIImage *img = [IBImage resizedImage:image size:self.frame.size]; //重绘图片，不然出现平铺效果
        [self setBackgroundColor:[UIColor colorWithPatternImage:img]];
    } else {
        self.layer.contents = (__bridge id _Nullable)(image.CGImage);
        self.layer.contentsScale = [UIScreen mainScreen].scale;
    }
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
- (void)setBottom:(CGFloat)bottom {
    
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

- (CGRect)visibleRect {
    CGRect rect = [self convertRect:self.frame toView:nil];
    CGRect intersectionRect = CGRectIntersection(rect, [UIScreen mainScreen].bounds);
    return intersectionRect;
}

- (CGRect)frameApplyTransform
{
    return self.frame;
}

- (void)setFrameApplyTransform:(CGRect)frameApplyTransform
{
    self.frame = CGRectApplyAffineTransformWithAnchorPoint(frameApplyTransform, self.transform, self.layer.anchorPoint);
}

- (UIEdgeInsets)safeAreaEdgeInsets
{
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

@end

