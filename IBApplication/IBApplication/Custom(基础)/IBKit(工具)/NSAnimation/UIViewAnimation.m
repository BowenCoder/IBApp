//
//  UIViewAnimation.m
//  IBApplication
//
//  Created by Bowen on 2018/6/29.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIViewAnimation.h"

NSString *const UIViewAnimationSlideName  = @"UIViewAnimationSlideName";
NSString *const UIViewAnimationFadeName   = @"UIViewAnimationFadeName";
NSString *const UIViewAnimationBackName   = @"UIViewAnimationBackName";
NSString *const UIViewAnimationPopName    = @"UIViewAnimationPopName";
NSString *const UIViewAnimationFallName   = @"UIViewAnimationFallName";
NSString *const UIViewAnimationFlyoutName = @"UIViewAnimationFlyoutName";

@interface UIViewAnimation () <CAAnimationDelegate>

@property (nonatomic, copy) UIViewAnimationHandle startHandle;
@property (nonatomic, copy) UIViewAnimationHandle endHandle;
@property (nonatomic, strong) UIView *currentView;
@property (nonatomic, assign) NSTimeInterval duration;

@end

@implementation UIViewAnimation

- (void)dealloc {
    NSLog(@"%s", __func__);
}

+ (CGPoint)viewCenter:(CGRect)enclosingViewFrame viewFrame:(CGRect)viewFrame viewCenter:(CGPoint)viewCenter direction:(UIViewAnimationDirection)direction {
    
    switch (direction) {
        case UIViewAnimationBottom: {
            CGFloat extraOffset = viewFrame.size.height / 2;
            return CGPointMake(viewCenter.x, enclosingViewFrame.size.height + extraOffset);
            break;
        }
        case UIViewAnimationTop: {
            CGFloat extraOffset = viewFrame.size.height / 2;
            return CGPointMake(viewCenter.x, enclosingViewFrame.origin.y - extraOffset);
            break;
        }
        case UIViewAnimationLeft: {
            CGFloat extraOffset = viewFrame.size.width / 2;
            return CGPointMake(enclosingViewFrame.origin.x - extraOffset, viewCenter.y);
            break;
        }
        case UIViewAnimationRight: {
            CGFloat extraOffset = viewFrame.size.width / 2;
            return CGPointMake(enclosingViewFrame.size.width + extraOffset, viewCenter.y);
            break;
        }
        case UIViewAnimationBottomLeft: {
            CGFloat extraOffsetHeight = viewFrame.size.height / 2;
            CGFloat extraOffsetWidth = viewFrame.size.width / 2;
            return CGPointMake(enclosingViewFrame.origin.x - extraOffsetWidth, enclosingViewFrame.size.height + extraOffsetHeight);
            break;
        }
        case UIViewAnimationTopLeft: {
            CGFloat extraOffsetHeight = viewFrame.size.height / 2;
            CGFloat extraOffsetWidth = viewFrame.size.width / 2;
            return CGPointMake(enclosingViewFrame.origin.x - extraOffsetWidth, enclosingViewFrame.origin.y - extraOffsetHeight);
            break;
        }
        case UIViewAnimationBottomRight: {
            CGFloat extraOffsetHeight = viewFrame.size.height / 2;
            CGFloat extraOffsetWidth = viewFrame.size.width / 2;
            return CGPointMake(enclosingViewFrame.size.width + extraOffsetWidth, enclosingViewFrame.size.height + extraOffsetHeight);
            break;
        }
        case UIViewAnimationTopRight: {
            CGFloat extraOffsetHeight = viewFrame.size.height / 2;
            CGFloat extraOffsetWidth = viewFrame.size.width / 2;
            return CGPointMake(enclosingViewFrame.size.width + extraOffsetWidth, enclosingViewFrame.origin.y - extraOffsetHeight);
            break;
        }
    }
    return CGPointZero;
}

+ (CGPoint)screenCenter:(CGRect)viewFrame viewCenter:(CGPoint)viewCenter direction:(UIViewAnimationDirection)direction {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        CGFloat swap = screenRect.size.height;
        screenRect.size.height = screenRect.size.width;
        screenRect.size.width = swap;
    }
    switch (direction) {
        case UIViewAnimationBottom: {
            CGFloat extraOffset = viewFrame.size.height / 2;
            return CGPointMake(viewCenter.x, screenRect.size.height + extraOffset);
            break;
        }
        case UIViewAnimationTop: {
            CGFloat extraOffset = viewFrame.size.height / 2;
            return CGPointMake(viewCenter.x, screenRect.origin.y - extraOffset);
            break;
        }
        case UIViewAnimationLeft: {
            CGFloat extraOffset = viewFrame.size.width / 2;
            return CGPointMake(screenRect.origin.x - extraOffset, viewCenter.y);
            break;
        }
        case UIViewAnimationRight: {
            CGFloat extraOffset = viewFrame.size.width / 2;
            return CGPointMake(screenRect.size.width + extraOffset, viewCenter.y);
            break;
        }
        default:
            break;
    }
    return [UIViewAnimation viewCenter:[[UIScreen mainScreen] bounds] viewFrame:viewFrame viewCenter:viewCenter direction:direction];
}

+ (CGPoint)overshootPoint:(CGPoint)point direction:(UIViewAnimationDirection)direction threshold:(CGFloat)threshold {
    CGPoint overshootPoint = CGPointMake(0, 0);
    if(direction == UIViewAnimationTop || direction == UIViewAnimationBottom) {
        overshootPoint = CGPointMake(point.x, point.y + ((direction == UIViewAnimationBottom ? -1 : 1) * threshold));
    }
    if (direction == UIViewAnimationLeft || direction == UIViewAnimationRight){
        overshootPoint = CGPointMake(point.x + ((direction == UIViewAnimationRight ? -1 : 1) * threshold), point.y);
    }
    if (direction == UIViewAnimationTopLeft){
        overshootPoint = CGPointMake(point.x + threshold, point.y + threshold);
    }
    if (direction == UIViewAnimationTopRight){
        overshootPoint = CGPointMake(point.x - threshold, point.y + threshold);
    }
    if (direction == UIViewAnimationBottomLeft){
        overshootPoint = CGPointMake(point.x + threshold, point.y - threshold);
    }
    if (direction == UIViewAnimationBottomRight){
        overshootPoint = CGPointMake(point.x - threshold, point.y - threshold);
    }
    
    return overshootPoint;
}

//计算离屏幕的边框最大的距离
+ (CGFloat)maxBorderDiameterForPoint:(CGPoint)point onView:(UIView *)view {
    
    CGPoint cornerPoints[] = {
        {0.0, 0.0},
        {0.0, view.bounds.size.height},
        {view.bounds.size.width, view.bounds.size.height},
        {view.bounds.size.width, 0.0}
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

@implementation UIViewAnimation (Animation)

+ (void)shake:(UIView *)view {
    
    [self _shake:view times:10 direction:1 currentTimes:0 withDelta:5 speed:0.03 shakeDirection:UIViewShakeDirectionHorizontal completion:nil];
}

+ (void)_shake:(UIView *)view times:(int)times direction:(int)direction currentTimes:(int)current withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(UIViewShakeDirection)shakeDirection completion:(void (^)(void))completionHandler {
    
    [UIView animateWithDuration:interval animations:^{
        view.layer.affineTransform = (shakeDirection == UIViewShakeDirectionHorizontal) ? CGAffineTransformMakeTranslation(delta * direction, 0) : CGAffineTransformMakeTranslation(0, delta * direction);
    } completion:^(BOOL finished) {
        if(current >= times) {
            [UIView animateWithDuration:interval animations:^{
                view.layer.affineTransform = CGAffineTransformIdentity;
            } completion:^(BOOL finished){
                if (completionHandler != nil) {
                    completionHandler();
                }
            }];
            return;
        }
        
        [self _shake:view
               times:times-1
           direction:direction * -1
        currentTimes:current + 1
           withDelta:delta
               speed:interval
      shakeDirection:shakeDirection
          completion:completionHandler];
    }];
}

+ (void)spread:(UIView *)view startPoint:(CGPoint)point duration:(NSTimeInterval)duration type:(UIViewAnimationType)type color:(UIColor *)color completion:(void (^)(BOOL finished))completion {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGFloat diameter = [UIViewAnimation maxBorderDiameterForPoint:point onView:view];
    shapeLayer.frame = CGRectMake(floor(point.x - diameter * 0.5), floor(point.y - diameter * 0.5), diameter, diameter);
    shapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0, 0.0, diameter, diameter)].CGPath;
    
    shapeLayer.fillColor = color.CGColor;
    CGFloat scale = 1.0 / shapeLayer.frame.size.width;
    NSString *timingFunctionName = kCAMediaTimingFunctionDefault;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    switch (type) {
        case UIViewAnimationTypeOpen: {
            
            [view.layer addSublayer:shapeLayer];
            animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1.0)];
            break;
        }
        case UIViewAnimationTypeClose: {
            
            [view.layer insertSublayer:shapeLayer atIndex:0];
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


+ (void)zoom:(UIView *)view duration:(float)duration isIn:(BOOL)isIn completion:(void (^)(void))completion {
    
    if (isIn) {
        view.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:duration animations:^{
            view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            completion();
        }];
    } else {
        view.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:duration animations:^{
            view.transform = CGAffineTransformMakeScale(0, 0);
        } completion:^(BOOL finished) {
            completion();
        }];
    }
    
}

+ (void)fade:(UIView *)view duration:(float)duration isIn:(BOOL)isIn completion:(void (^)(void))completion{
    
    if (isIn) {
        [view setAlpha:0.0];
        [UIView animateWithDuration:duration animations:^{
            [view setAlpha:1.0];
        } completion:^(BOOL finished) {
            completion();
        }];
    } else {
        [view setAlpha:1.0];
        [UIView animateWithDuration:duration animations:^{
            [view setAlpha:0.0];
        } completion:^(BOOL finished) {
            completion();
        }];
    }
}

+ (void)move:(UIView *)view duration:(float)duration distance:(CGFloat)distance direction:(UIViewAnimationDirection)direction completion:(void (^)(void))completion {
    
    switch (direction) {
        case UIViewAnimationLeft: {
            [UIView animateWithDuration:duration animations:^{
                view.center = CGPointMake(view.center.x - distance, view.center.y);
            } completion:^(BOOL finished) {
                completion();
            }];
        }
            break;
        case UIViewAnimationRight: {
            [UIView animateWithDuration:duration animations:^{
                view.center = CGPointMake(view.center.x + distance, view.center.y);
            } completion:^(BOOL finished) {
                completion();
            }];
        }
        case UIViewAnimationTop: {
            [UIView animateWithDuration:duration animations:^{
                view.center = CGPointMake(view.center.x, view.center.y - distance);
            } completion:^(BOOL finished) {
                completion();
            }];
        }
            break;
        case UIViewAnimationBottom: {
            [UIView animateWithDuration:duration animations:^{
                view.center = CGPointMake(view.center.x, view.center.y + distance);
            } completion:^(BOOL finished) {
                completion();
            }];
        }
            break;
        default:
            break;
    }
}

+ (void)rotate:(UIView *)view duration:(float)duration angle:(NSInteger)angle completion:(void (^)(void))completion {
    
    [UIView animateWithDuration:duration animations:^{
        view.layer.transform = CATransform3DRotate(view.layer.transform, M_PI*angle/180.0, 0, 0, 1);
    } completion:^(BOOL finished) {
        completion();
    }];
}

@end

@implementation UIViewAnimation (CoreAnimation)

- (CAAnimation *)slideAnimation:(UIView *)view
                         inView:(UIView *)enclosingView
                      direction:(UIViewAnimationDirection)direction
                       duration:(NSTimeInterval)duration
                          start:(UIViewAnimationHandle)startHandle
                            end:(UIViewAnimationHandle)endHandle
                           isIn:(BOOL)isIn {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    NSValue *fromValue;
    NSValue *toValue;
    if (isIn) {
        if (enclosingView) {
            fromValue = [NSValue valueWithCGPoint:[UIViewAnimation viewCenter:enclosingView.frame viewFrame:view.frame viewCenter:view.center direction:direction]];
        } else {
            fromValue = [NSValue valueWithCGPoint:[UIViewAnimation screenCenter:view.frame viewCenter:view.center direction:direction]];
        }
        toValue = [NSValue valueWithCGPoint:view.center];
    } else {
        fromValue = [NSValue valueWithCGPoint:view.center];
        if (enclosingView) {
            toValue = [NSValue valueWithCGPoint:[UIViewAnimation viewCenter:enclosingView.frame viewFrame:view.frame viewCenter:view.center direction:direction]];
        } else {
            toValue = [NSValue valueWithCGPoint:[UIViewAnimation screenCenter:view.frame viewCenter:view.center direction:direction]];
        }
    }

    animation.fromValue = fromValue;
    animation.toValue = toValue;
    CAAnimationGroup *group = [self animationGroup:view animations:@[animation] duration:duration start:startHandle end:endHandle];
    [view.layer addAnimation:group forKey:UIViewAnimationSlideName];
    return group;
}

- (CAAnimation *)fadeAnimation:(UIView *)view
                      duration:(NSTimeInterval)duration
                         start:(UIViewAnimationHandle)startHandle
                           end:(UIViewAnimationHandle)endHandle
                          isIn:(BOOL)isIn {

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    if (isIn) {
        animation.fromValue = @0.0;
        animation.toValue = @1.0;
    } else {
        animation.fromValue = @1.0;
        animation.toValue = @0.0;
    }
    
    CAAnimationGroup *group = [self animationGroup:view animations:@[animation] duration:duration start:startHandle end:endHandle];
    [view.layer addAnimation:group forKey:UIViewAnimationFadeName];
    return group;
}


- (CAAnimation *)backAnimation:(UIView *)view
                        inView:(UIView *)enclosingView
                     direction:(UIViewAnimationDirection)direction
                      duration:(NSTimeInterval)duration
                         start:(UIViewAnimationHandle)startHandle
                           end:(UIViewAnimationHandle)endHandle
                          fade:(BOOL)fade
                          isIn:(BOOL)isIn {

    CGPoint centerPoint;
    if (enclosingView) {
        centerPoint = [UIViewAnimation viewCenter:enclosingView.frame viewFrame:view.frame viewCenter:view.center direction:direction];
    } else {
        centerPoint = [UIViewAnimation screenCenter:view.frame viewCenter:view.center direction:direction];
    }
    CGPoint path[3];
    if (isIn) {
        path[0] = centerPoint;
        path[1] = [UIViewAnimation overshootPoint:view.center direction:direction threshold:(10 * 1.15)];
        path[2] = view.center;
    } else {
        path[0] = view.center;
        path[1] = [UIViewAnimation overshootPoint:view.center direction:direction threshold:10];
        path[2] = centerPoint;
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef thePath = CGPathCreateMutable();
    CGPathAddLines(thePath, NULL, path, 3);
    animation.path = thePath;
    CGPathRelease(thePath);
    NSArray *animations;
    if(fade) {
        CAAnimation *fade = [self fadeAnimation:view duration:duration start:startHandle end:endHandle isIn:isIn];
        animations = @[animation, fade];
    } else {
        animations = @[animation];
    }
    CAAnimationGroup *group = [self animationGroup:view animations:animations duration:duration start:startHandle end:endHandle];
    [view.layer addAnimation:group forKey:UIViewAnimationBackName];
    return nil;
}

- (CAAnimation *)popAnimation:(UIView *)view
                     duration:(NSTimeInterval)duration
                        start:(UIViewAnimationHandle)startHandle
                          end:(UIViewAnimationHandle)endHandle
                         isIn:(BOOL)isIn {
    
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    if (isIn) {
        scale.values = @[@0.5, @1.2, @0.85, @1.0];
    } else {
        scale.values = @[@1.0, @1.2, @0.75];
    }
    
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    if (isIn) {
        fade.fromValue = @0.0;
        fade.toValue = @1.0;
    } else {
        fade.fromValue = @1.0;
        fade.toValue = @0.0;
    }
    
    CAAnimationGroup *group = [self animationGroup:view animations:@[scale, fade] duration:duration start:startHandle end:endHandle];
    [view.layer addAnimation:group forKey:UIViewAnimationPopName];
    
    return group;
}

- (CAAnimation *)fallAnimation:(UIView *)view
                      duration:(NSTimeInterval)duration
                         start:(UIViewAnimationHandle)startHandle
                           end:(UIViewAnimationHandle)endHandle
                          isIn:(BOOL)isIn {

    CABasicAnimation *fall = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    if (isIn) {
        fall.fromValue = @2.0;
        fall.toValue = @1.0;
    } else {
        fall.fromValue = @1.0;
        fall.toValue = @0.1;
    }
    
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    if (isIn) {
        fade.fromValue = @0.0;
        fade.toValue = @1.0;
    } else {
        fade.fromValue = @1.0;
        fade.toValue = @0.0;
    }
    
    CAAnimationGroup *group = [self animationGroup:view animations:@[fall, fade] duration:duration start:startHandle end:endHandle];
    [view.layer addAnimation:group forKey:UIViewAnimationFallName];
    return group;
}

- (CAAnimation *)flyoutAnimation:(UIView *)view
                        duration:(NSTimeInterval)duration
                           start:(UIViewAnimationHandle)startHandle
                             end:(UIViewAnimationHandle)endHandle {
    self.currentView = view;

    CABasicAnimation *fly = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    fly.toValue = @2.0;
    
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.toValue = @0.0;
    
    CAAnimationGroup *group = [self animationGroup:view animations:@[fly, fade] duration:duration start:startHandle end:endHandle];
    [view.layer addAnimation:group forKey:UIViewAnimationFlyoutName];
    return group;

}

- (CAAnimationGroup *)animationGroup:(UIView *)view
                          animations:(NSArray *)animations
                            duration:(NSTimeInterval)duration
                               start:(UIViewAnimationHandle)startHandle
                                 end:(UIViewAnimationHandle)endHandle {
    self.currentView = view;
    self.duration = duration;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithArray:animations];
    group.delegate = self;
    group.duration = duration;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeBoth;
    self.startHandle = startHandle;
    self.endHandle = endHandle;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    return group;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim {
    
    if (self.startHandle) {
        self.startHandle(anim);
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

    if (self.endHandle) {
        self.endHandle(anim);
    }

    if (self.moveModelLayer && self.currentView) {
        CGPoint position = self.currentView.layer.presentationLayer.position;
        self.currentView.layer.modelLayer.position = position;
    }
    
    if (self.removeAnimation && self.currentView && flag) {
        [self _removeAnimations];
    } else { //解决视图没有被添加，执行动画提前结束，在真正结束时移除动画
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _removeAnimations];
        });
    }
}

- (void)_removeAnimations {

    if ([self.currentView.layer animationForKey:UIViewAnimationSlideName]) {
        [self.currentView.layer removeAnimationForKey:UIViewAnimationSlideName];
    }
    if ([self.currentView.layer animationForKey:UIViewAnimationFadeName]) {
        [self.currentView.layer removeAnimationForKey:UIViewAnimationFadeName];
    }
    if ([self.currentView.layer animationForKey:UIViewAnimationBackName]) {
        [self.currentView.layer removeAnimationForKey:UIViewAnimationBackName];
    }
    if ([self.currentView.layer animationForKey:UIViewAnimationPopName]) {
        [self.currentView.layer removeAnimationForKey:UIViewAnimationPopName];
    }
    if ([self.currentView.layer animationForKey:UIViewAnimationFallName]) {
        [self.currentView.layer removeAnimationForKey:UIViewAnimationFallName];
    }
    if ([self.currentView.layer animationForKey:UIViewAnimationFlyoutName]) {
        [self.currentView.layer removeAnimationForKey:UIViewAnimationFlyoutName];
    }
}

@end
