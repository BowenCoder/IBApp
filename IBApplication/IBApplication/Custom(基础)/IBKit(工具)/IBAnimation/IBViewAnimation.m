//
//  IBViewAnimation.m
//  IBApplication
//
//  Created by Bowen on 2018/6/29.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBViewAnimation.h"

NSString *const IBViewAnimationSlideName  = @"IBViewAnimationSlideName";
NSString *const IBViewAnimationFadeName   = @"IBViewAnimationFadeName";
NSString *const IBViewAnimationBackName   = @"IBViewAnimationBackName";
NSString *const IBViewAnimationPopName    = @"IBViewAnimationPopName";
NSString *const IBViewAnimationFallName   = @"IBViewAnimationFallName";
NSString *const IBViewAnimationFlyoutName = @"IBViewAnimationFlyoutName";

@interface IBViewAnimation () <CAAnimationDelegate>

@property (nonatomic, copy) IBViewAnimationHandle startHandle;
@property (nonatomic, copy) IBViewAnimationHandle endHandle;
@property (nonatomic, strong) UIView *currentView;
@property (nonatomic, assign) NSTimeInterval duration;

@end

@implementation IBViewAnimation

- (void)dealloc {
    NSLog(@"%s", __func__);
}

+ (CGPoint)viewCenter:(CGRect)enclosingViewFrame viewFrame:(CGRect)viewFrame viewCenter:(CGPoint)viewCenter direction:(IBViewAnimationDirection)direction {
    
    switch (direction) {
        case IBViewAnimationBottom: {
            CGFloat extraOffset = viewFrame.size.height / 2;
            return CGPointMake(viewCenter.x, enclosingViewFrame.size.height + extraOffset);
            break;
        }
        case IBViewAnimationTop: {
            CGFloat extraOffset = viewFrame.size.height / 2;
            return CGPointMake(viewCenter.x, enclosingViewFrame.origin.y - extraOffset);
            break;
        }
        case IBViewAnimationLeft: {
            CGFloat extraOffset = viewFrame.size.width / 2;
            return CGPointMake(enclosingViewFrame.origin.x - extraOffset, viewCenter.y);
            break;
        }
        case IBViewAnimationRight: {
            CGFloat extraOffset = viewFrame.size.width / 2;
            return CGPointMake(enclosingViewFrame.size.width + extraOffset, viewCenter.y);
            break;
        }
        case IBViewAnimationBottomLeft: {
            CGFloat extraOffsetHeight = viewFrame.size.height / 2;
            CGFloat extraOffsetWidth = viewFrame.size.width / 2;
            return CGPointMake(enclosingViewFrame.origin.x - extraOffsetWidth, enclosingViewFrame.size.height + extraOffsetHeight);
            break;
        }
        case IBViewAnimationTopLeft: {
            CGFloat extraOffsetHeight = viewFrame.size.height / 2;
            CGFloat extraOffsetWidth = viewFrame.size.width / 2;
            return CGPointMake(enclosingViewFrame.origin.x - extraOffsetWidth, enclosingViewFrame.origin.y - extraOffsetHeight);
            break;
        }
        case IBViewAnimationBottomRight: {
            CGFloat extraOffsetHeight = viewFrame.size.height / 2;
            CGFloat extraOffsetWidth = viewFrame.size.width / 2;
            return CGPointMake(enclosingViewFrame.size.width + extraOffsetWidth, enclosingViewFrame.size.height + extraOffsetHeight);
            break;
        }
        case IBViewAnimationTopRight: {
            CGFloat extraOffsetHeight = viewFrame.size.height / 2;
            CGFloat extraOffsetWidth = viewFrame.size.width / 2;
            return CGPointMake(enclosingViewFrame.size.width + extraOffsetWidth, enclosingViewFrame.origin.y - extraOffsetHeight);
            break;
        }
    }
    return CGPointZero;
}

+ (CGPoint)screenCenter:(CGRect)viewFrame viewCenter:(CGPoint)viewCenter direction:(IBViewAnimationDirection)direction {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        CGFloat swap = screenRect.size.height;
        screenRect.size.height = screenRect.size.width;
        screenRect.size.width = swap;
    }
    switch (direction) {
        case IBViewAnimationBottom: {
            CGFloat extraOffset = viewFrame.size.height / 2;
            return CGPointMake(viewCenter.x, screenRect.size.height + extraOffset);
            break;
        }
        case IBViewAnimationTop: {
            CGFloat extraOffset = viewFrame.size.height / 2;
            return CGPointMake(viewCenter.x, screenRect.origin.y - extraOffset);
            break;
        }
        case IBViewAnimationLeft: {
            CGFloat extraOffset = viewFrame.size.width / 2;
            return CGPointMake(screenRect.origin.x - extraOffset, viewCenter.y);
            break;
        }
        case IBViewAnimationRight: {
            CGFloat extraOffset = viewFrame.size.width / 2;
            return CGPointMake(screenRect.size.width + extraOffset, viewCenter.y);
            break;
        }
        default:
            break;
    }
    return [IBViewAnimation viewCenter:[[UIScreen mainScreen] bounds] viewFrame:viewFrame viewCenter:viewCenter direction:direction];
}

+ (CGPoint)overshootPoint:(CGPoint)point direction:(IBViewAnimationDirection)direction threshold:(CGFloat)threshold {
    CGPoint overshootPoint = CGPointMake(0, 0);
    if(direction == IBViewAnimationTop || direction == IBViewAnimationBottom) {
        overshootPoint = CGPointMake(point.x, point.y + ((direction == IBViewAnimationBottom ? -1 : 1) * threshold));
    }
    if (direction == IBViewAnimationLeft || direction == IBViewAnimationRight){
        overshootPoint = CGPointMake(point.x + ((direction == IBViewAnimationRight ? -1 : 1) * threshold), point.y);
    }
    if (direction == IBViewAnimationTopLeft){
        overshootPoint = CGPointMake(point.x + threshold, point.y + threshold);
    }
    if (direction == IBViewAnimationTopRight){
        overshootPoint = CGPointMake(point.x - threshold, point.y + threshold);
    }
    if (direction == IBViewAnimationBottomLeft){
        overshootPoint = CGPointMake(point.x + threshold, point.y - threshold);
    }
    if (direction == IBViewAnimationBottomRight){
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

#pragma mark - UIViewAnimation

+ (void)shake:(UIView *)view {
    
    [self _shake:view times:10 direction:1 currentTimes:0 withDelta:5 speed:0.03 shakeDirection:IBViewShakeHorizontal completion:nil];
}

+ (void)_shake:(UIView *)view times:(int)times direction:(int)direction currentTimes:(int)current withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(IBViewShakeDirection)shakeDirection completion:(void (^)(void))completionHandler {
    
    [UIView animateWithDuration:interval animations:^{
        view.layer.affineTransform = (shakeDirection == IBViewShakeHorizontal) ? CGAffineTransformMakeTranslation(delta * direction, 0) : CGAffineTransformMakeTranslation(0, delta * direction);
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

+ (void)spread:(UIView *)view startPoint:(CGPoint)point duration:(NSTimeInterval)duration type:(IBViewAnimationType)type color:(UIColor *)color completion:(void (^)(BOOL finished))completion {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGFloat diameter = [IBViewAnimation maxBorderDiameterForPoint:point onView:view];
    shapeLayer.frame = CGRectMake(floor(point.x - diameter * 0.5), floor(point.y - diameter * 0.5), diameter, diameter);
    shapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0, 0.0, diameter, diameter)].CGPath;
    
    shapeLayer.fillColor = color.CGColor;
    CGFloat scale = 1.0 / shapeLayer.frame.size.width;
    NSString *timingFunctionName = kCAMediaTimingFunctionDefault;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    switch (type) {
        case IBViewAnimationOpen: {
            
            [view.layer addSublayer:shapeLayer];
            animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1.0)];
            break;
        }
        case IBViewAnimationClose: {
            
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

+ (void)move:(UIView *)view duration:(float)duration distance:(CGFloat)distance direction:(IBViewAnimationDirection)direction completion:(void (^)(void))completion {
    
    switch (direction) {
        case IBViewAnimationLeft: {
            [UIView animateWithDuration:duration animations:^{
                view.center = CGPointMake(view.center.x - distance, view.center.y);
            } completion:^(BOOL finished) {
                completion();
            }];
        }
            break;
        case IBViewAnimationRight: {
            [UIView animateWithDuration:duration animations:^{
                view.center = CGPointMake(view.center.x + distance, view.center.y);
            } completion:^(BOOL finished) {
                completion();
            }];
        }
        case IBViewAnimationTop: {
            [UIView animateWithDuration:duration animations:^{
                view.center = CGPointMake(view.center.x, view.center.y - distance);
            } completion:^(BOOL finished) {
                completion();
            }];
        }
            break;
        case IBViewAnimationBottom: {
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

#pragma mark - CoreAnimation

- (CAAnimation *)slideAnimation:(UIView *)view
                         inView:(UIView *)enclosingView
                      direction:(IBViewAnimationDirection)direction
                       duration:(NSTimeInterval)duration
                          start:(IBViewAnimationHandle)startHandle
                            end:(IBViewAnimationHandle)endHandle
                           isIn:(BOOL)isIn {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    NSValue *fromValue;
    NSValue *toValue;
    if (isIn) {
        if (enclosingView) {
            fromValue = [NSValue valueWithCGPoint:[IBViewAnimation viewCenter:enclosingView.frame viewFrame:view.frame viewCenter:view.center direction:direction]];
        } else {
            fromValue = [NSValue valueWithCGPoint:[IBViewAnimation screenCenter:view.frame viewCenter:view.center direction:direction]];
        }
        toValue = [NSValue valueWithCGPoint:view.center];
    } else {
        fromValue = [NSValue valueWithCGPoint:view.center];
        if (enclosingView) {
            toValue = [NSValue valueWithCGPoint:[IBViewAnimation viewCenter:enclosingView.frame viewFrame:view.frame viewCenter:view.center direction:direction]];
        } else {
            toValue = [NSValue valueWithCGPoint:[IBViewAnimation screenCenter:view.frame viewCenter:view.center direction:direction]];
        }
    }

    animation.fromValue = fromValue;
    animation.toValue = toValue;
    CAAnimationGroup *group = [self animationGroup:view animations:@[animation] duration:duration start:startHandle end:endHandle];
    [view.layer addAnimation:group forKey:IBViewAnimationSlideName];
    return group;
}

- (CAAnimation *)fadeAnimation:(UIView *)view
                      duration:(NSTimeInterval)duration
                         start:(IBViewAnimationHandle)startHandle
                           end:(IBViewAnimationHandle)endHandle
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
    [view.layer addAnimation:group forKey:IBViewAnimationFadeName];
    return group;
}


- (CAAnimation *)backAnimation:(UIView *)view
                        inView:(UIView *)enclosingView
                     direction:(IBViewAnimationDirection)direction
                      duration:(NSTimeInterval)duration
                         start:(IBViewAnimationHandle)startHandle
                           end:(IBViewAnimationHandle)endHandle
                          fade:(BOOL)fade
                          isIn:(BOOL)isIn {

    CGPoint centerPoint;
    if (enclosingView) {
        centerPoint = [IBViewAnimation viewCenter:enclosingView.frame viewFrame:view.frame viewCenter:view.center direction:direction];
    } else {
        centerPoint = [IBViewAnimation screenCenter:view.frame viewCenter:view.center direction:direction];
    }
    CGPoint path[3];
    if (isIn) {
        path[0] = centerPoint;
        path[1] = [IBViewAnimation overshootPoint:view.center direction:direction threshold:(10 * 1.15)];
        path[2] = view.center;
    } else {
        path[0] = view.center;
        path[1] = [IBViewAnimation overshootPoint:view.center direction:direction threshold:10];
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
    [view.layer addAnimation:group forKey:IBViewAnimationBackName];
    return nil;
}

- (CAAnimation *)popAnimation:(UIView *)view
                     duration:(NSTimeInterval)duration
                        start:(IBViewAnimationHandle)startHandle
                          end:(IBViewAnimationHandle)endHandle
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
    [view.layer addAnimation:group forKey:IBViewAnimationPopName];
    
    return group;
}

- (CAAnimation *)fallAnimation:(UIView *)view
                      duration:(NSTimeInterval)duration
                         start:(IBViewAnimationHandle)startHandle
                           end:(IBViewAnimationHandle)endHandle
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
    [view.layer addAnimation:group forKey:IBViewAnimationFallName];
    return group;
}

- (CAAnimation *)flyoutAnimation:(UIView *)view
                        duration:(NSTimeInterval)duration
                           start:(IBViewAnimationHandle)startHandle
                             end:(IBViewAnimationHandle)endHandle {
    self.currentView = view;

    CABasicAnimation *fly = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    fly.toValue = @2.0;
    
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.toValue = @0.0;
    
    CAAnimationGroup *group = [self animationGroup:view animations:@[fly, fade] duration:duration start:startHandle end:endHandle];
    [view.layer addAnimation:group forKey:IBViewAnimationFlyoutName];
    return group;

}

- (CAAnimationGroup *)animationGroup:(UIView *)view
                          animations:(NSArray *)animations
                            duration:(NSTimeInterval)duration
                               start:(IBViewAnimationHandle)startHandle
                                 end:(IBViewAnimationHandle)endHandle {
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

/**
 此方法返回动画不一定结束
 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

    if (flag) { //标志动画是否结束
        [self _animationRealStop:anim];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _animationRealStop:anim];
        });
    }
}

- (void)_animationRealStop:(CAAnimation *)anim {
    
    if (self.moveModelLayer && self.currentView) {
        CGPoint position = self.currentView.layer.presentationLayer.position;
        self.currentView.layer.modelLayer.position = position;
    }
    if (self.removeAnimation && self.currentView) {
        [self _removeAnimations];
    }
    
    if (self.endHandle) {
        self.endHandle(anim);
    }
}

- (void)_removeAnimations {

    if ([self.currentView.layer animationForKey:IBViewAnimationSlideName]) {
        [self.currentView.layer removeAnimationForKey:IBViewAnimationSlideName];
    }
    if ([self.currentView.layer animationForKey:IBViewAnimationFadeName]) {
        [self.currentView.layer removeAnimationForKey:IBViewAnimationFadeName];
    }
    if ([self.currentView.layer animationForKey:IBViewAnimationBackName]) {
        [self.currentView.layer removeAnimationForKey:IBViewAnimationBackName];
    }
    if ([self.currentView.layer animationForKey:IBViewAnimationPopName]) {
        [self.currentView.layer removeAnimationForKey:IBViewAnimationPopName];
    }
    if ([self.currentView.layer animationForKey:IBViewAnimationFallName]) {
        [self.currentView.layer removeAnimationForKey:IBViewAnimationFallName];
    }
    if ([self.currentView.layer animationForKey:IBViewAnimationFlyoutName]) {
        [self.currentView.layer removeAnimationForKey:IBViewAnimationFlyoutName];
    }
}

@end
