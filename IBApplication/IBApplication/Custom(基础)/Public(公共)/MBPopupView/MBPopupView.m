//
//  MBPopupView.m
//  IBApplication
//
//  Created by Bowen on 2020/1/14.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBPopupView.h"
#import <objc/runtime.h>

static void *MBPopupViewParametersKey = &MBPopupViewParametersKey;
static void *MBPopupViewNSTimerKey = &MBPopupViewNSTimerKey;

@interface MBPopupView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *superview;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) CGFloat dropAngle;
@property (nonatomic, assign) CGPoint markerCenter;
@property (nonatomic, assign) MBPopupMaskType maskType;

@end

@implementation MBPopupView

+ (instancetype)popupViewWithMaskType:(MBPopupMaskType)maskType {
    return [[self alloc] initWithMaskType:maskType];
}

- (instancetype)init {
    return [self initWithMaskType:MBPopupMaskTypeBlackTranslucent];
}

- (instancetype)initWithMaskType:(MBPopupMaskType)maskType {
    if (self = [super init]) {
        _isPresenting = NO;
        _maskType = maskType;
        _layoutType = MBPopupLayoutTypeCenter;
        _dismissOnMaskTouched = YES;
        
        // setter
        self.maskAlpha = 0.5f;
        self.slideStyle = MBPopupSlideStyleFade;
        self.dismissOppositeDirection = NO;
        self.allowPan = NO;
    
        // superview
        _superview = [self frontWindow];
        
        // maskView
        if (maskType == MBPopupMaskTypeBlackBlur || maskType == MBPopupMaskTypeWhiteBlur) {
            _maskView = [[UIView alloc] initWithFrame:_superview.bounds];
            UIVisualEffectView *visualEffectView;
            visualEffectView = [[UIVisualEffectView alloc] init];
            visualEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            visualEffectView.frame = _superview.bounds;
            [_maskView insertSubview:visualEffectView atIndex:0];
        } else {
            _maskView = [[UIView alloc] initWithFrame:_superview.bounds];
        }
        
        switch (maskType) {
            case MBPopupMaskTypeBlackBlur: {
                UIVisualEffectView *effectView = (UIVisualEffectView *)_maskView.subviews.firstObject;
                effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            } break;
            case MBPopupMaskTypeWhiteBlur: {
                UIVisualEffectView *effectView = (UIVisualEffectView *)_maskView.subviews.firstObject;
                effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            } break;
            case MBPopupMaskTypeWhite:
                _maskView.backgroundColor = [UIColor whiteColor];
                break;
            case MBPopupMaskTypeClear:
                _maskView.backgroundColor = [UIColor clearColor];
                break;
            default: // MBPopupMaskTypeBlackTranslucent
                _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:_maskAlpha];
                break;
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleTap:)];
        tap.delegate = self;
        [_maskView addGestureRecognizer:tap];
        
        // popupView
        _popupView = [[UIView alloc] init];
        _popupView.backgroundColor = [UIColor clearColor];
        
        // addSubview
        [_maskView addSubview:_popupView];
        [_superview addSubview:_maskView];
        
        // Observer statusBar orientation changes.
        [self bindNotificationEvent];
    }
    return self;
}

#pragma mark - Setter

- (void)setDismissOppositeDirection:(BOOL)dismissOppositeDirection {
    _dismissOppositeDirection = dismissOppositeDirection;
    objc_setAssociatedObject(self, _cmd, @(dismissOppositeDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setSlideStyle:(MBPopupSlideStyle)slideStyle {
    _slideStyle = slideStyle;
    objc_setAssociatedObject(self, _cmd, @(slideStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    if (_maskType != MBPopupMaskTypeBlackTranslucent) return;
    _maskAlpha = maskAlpha;
    _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:_maskAlpha];
}

- (void)setAllowPan:(BOOL)allowPan {
    if (!allowPan) return;
    if (_allowPan != allowPan) {
        _allowPan = allowPan;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_popupView addGestureRecognizer:pan];
    }
}

#pragma mark - Present

- (void)presentContentView:(UIView *)contentView {
    [self presentContentView:contentView duration:0.25 springAnimated:NO];
}

- (void)presentContentView:(UIView *)contentView displayTime:(NSTimeInterval)displayTime {
    [self presentContentView:contentView duration:0.25 springAnimated:NO inView:nil displayTime:displayTime];
}

- (void)presentContentView:(UIView *)contentView duration:(NSTimeInterval)duration springAnimated:(BOOL)isSpringAnimated {
    [self presentContentView:contentView duration:duration springAnimated:isSpringAnimated inView:nil];
}

- (void)presentContentView:(UIView *)contentView
                  duration:(NSTimeInterval)duration
            springAnimated:(BOOL)isSpringAnimated
                    inView:(UIView *)sView {
    [self presentContentView:contentView duration:duration springAnimated:isSpringAnimated inView:sView displayTime:0];
}

- (void)presentContentView:(UIView *)contentView
                  duration:(NSTimeInterval)duration
            springAnimated:(BOOL)isSpringAnimated
                    inView:(UIView *)sView
               displayTime:(NSTimeInterval)displayTime {
 
    if (self.isPresenting) return;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setValue:@(duration) forKey:@"MB_duration"];
    [parameters setValue:@(isSpringAnimated) forKey:@"MB_springAnimated"];
    objc_setAssociatedObject(self, MBPopupViewParametersKey, parameters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (nil != self.willPresent) {
        self.willPresent(self);
    }
    
    if (nil != sView) {
        _superview = sView;
        _maskView.frame = _superview.frame;
    }
    [self addContentView:contentView];
    if (![_superview.subviews containsObject:_maskView]) {
        [_superview addSubview:_maskView];
    }
    
    [self prepareDropAnimated];
    [self prepareBackground];
    _popupView.userInteractionEnabled = NO;
    _popupView.center = [self prepareCenter];
    
    void (^presentCallback)(void) = ^() {
        self->_isPresenting = YES;
        self.popupView.userInteractionEnabled = YES;
        if (nil != self.didPresent) {
            self.didPresent(self);
        }
        if (displayTime) {
            NSTimer *timer = [NSTimer timerWithTimeInterval:displayTime target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            objc_setAssociatedObject(self, MBPopupViewNSTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    };
    
    if (isSpringAnimated) {
        [UIView animateWithDuration:duration delay:0.f usingSpringWithDamping:0.6 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveLinear animations:^{
            
            [self finishedDropAnimated];
            [self finishedBackground];
            self.popupView.center = [self finishedCenter];
            
        } completion:^(BOOL finished) {
            
            if (finished) presentCallback();
            
        }];
    } else {
        [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
            
            [self finishedDropAnimated];
            [self finishedBackground];
            self.popupView.center = [self finishedCenter];
            
        } completion:^(BOOL finished) {
            
            if (finished) presentCallback();
            
        }];
    }
}

#pragma mark - Dismiss

- (void)fadeDismiss {
    objc_setAssociatedObject(self, _cmd, @(_slideStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _slideStyle = MBPopupSlideStyleFade;
    [self dismiss];
}

- (void)dismiss {
    id object = objc_getAssociatedObject(self, MBPopupViewParametersKey);
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        NSTimeInterval duration = 0.0;
        NSNumber *durationNumber = [object valueForKey:@"MB_duration"];
        if (nil != durationNumber) duration = durationNumber.doubleValue;
        BOOL flag = NO;
        NSNumber *flagNumber = [object valueForKey:@"MB_springAnimated"];
        if (nil != flagNumber) flag = flagNumber.boolValue;
        [self dismissWithDuration:duration springAnimated:flag];
    }
}

- (void)dismissWithDuration:(NSTimeInterval)duration springAnimated:(BOOL)isSpringAnimated {
    [self destroyTimer];
    
    if (!self.isPresenting) return;
    
    if (nil != self.willDismiss) {
        self.willDismiss(self);
    }
    void (^dismissCallback)(void) = ^() {
        self.slideStyle = [objc_getAssociatedObject(self, @selector(fadeDismiss)) integerValue];
        [self removeSubviews];
        self->_isPresenting = NO;
        self.popupView.transform = CGAffineTransformIdentity;
        if (nil != self.didDismiss) {
            self.didDismiss(self);
        }
    };
    
    UIViewAnimationOptions (^animOpts)(MBPopupSlideStyle) = ^(MBPopupSlideStyle slide){
        if (slide != MBPopupSlideStyleShrinkInOut) {
            return UIViewAnimationOptionCurveLinear;
        }
        return UIViewAnimationOptionCurveEaseInOut;
    };
    
    if (isSpringAnimated) {
        duration *= 0.75;
        NSTimeInterval duration1 = duration * 0.25, duration2 = duration - duration1;
        
        [UIView animateWithDuration:duration1 delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self bufferBackground];
            self.popupView.center = [self bufferCenter:30];
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration2 delay:0.f options:animOpts(self.slideStyle) animations:^{
                
                [self dismissedDropAnimated];
                [self dismissedBackground];
                self.popupView.center = [self dismissedCenter];
                
            } completion:^(BOOL finished) {
                if (finished) dismissCallback();
            }];
            
        }];
        
    } else {
        [UIView animateWithDuration:duration delay:0.f options:animOpts(self.slideStyle) animations:^{
            
            [self dismissedDropAnimated];
            [self dismissedBackground];
            self.popupView.center = [self dismissedCenter];

        } completion:^(BOOL finished) {
            if (finished) dismissCallback();
        }];
    }
}

#pragma mark - Add contentView

- (void)addContentView:(UIView *)contentView {
    if (!contentView) {
        if (nil != _popupView.superview) [_popupView removeFromSuperview];
        return;
    }
    _contentView = contentView;
    if (_contentView.superview != _popupView) {
        _contentView.frame = (CGRect){.origin = CGPointZero, .size = contentView.frame.size};
        _popupView.frame = _contentView.frame;
        _popupView.backgroundColor = _contentView.backgroundColor;
        if (_contentView.layer.cornerRadius) {
            _popupView.layer.cornerRadius = _contentView.layer.cornerRadius;
            _popupView.clipsToBounds = NO;
        }
        [_popupView addSubview:_contentView];
    }
}

- (void)removeSubviews {
    if (_popupView.subviews.count > 0) {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }
    [_maskView removeFromSuperview];
}

#pragma mark - Drop animated

- (void)dropAnimatedWithRotateAngle:(CGFloat)angle {
    _dropAngle = angle;
    _slideStyle = MBPopupSlideStyleFromTop;
}

- (BOOL)dropSupport {
    return (_layoutType == MBPopupLayoutTypeCenter && _slideStyle == MBPopupSlideStyleFromTop);
}

static CGFloat MB_randomValue(int i, int j) {
    if (arc4random() % 2) return i;
    return j;
}

- (void)prepareDropAnimated {
    if (_dropAngle && [self dropSupport]) {
        _dismissOppositeDirection = YES;
        CGFloat ty = (_maskView.bounds.size.height + _popupView.frame.size.height) / 2;
        CATransform3D transform = CATransform3DMakeTranslation(0, -ty, 0);
        transform = CATransform3DRotate(transform,
                                        MB_randomValue(_dropAngle, -_dropAngle) * M_PI / 180,
                                        0, 0, 1.0);
        _popupView.layer.transform = transform;
    }
}

- (void)finishedDropAnimated {
    if (_dropAngle && [self dropSupport]) {
        _popupView.layer.transform = CATransform3DIdentity;
    }
}

- (void)dismissedDropAnimated {
    if (_dropAngle && [self dropSupport]) {
        CGFloat ty = _maskView.bounds.size.height;
        CATransform3D transform = CATransform3DMakeTranslation(0, ty, 0);
        transform = CATransform3DRotate(transform,
                                        MB_randomValue(_dropAngle, -_dropAngle) * M_PI / 180,
                                        0, 0, 1.0);
        _popupView.layer.transform = transform;
    }
}

#pragma mark - Mask view background

- (void)prepareBackground {
    switch (_maskType) {
        case MBPopupMaskTypeBlackBlur:
        case MBPopupMaskTypeWhiteBlur:
            _maskView.alpha = 1;
            break;
        default:
            _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
            break;
    }
}

- (void)finishedBackground {
    switch (_maskType) {
        case MBPopupMaskTypeBlackTranslucent:
            _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:_maskAlpha];
            break;
        case MBPopupMaskTypeWhite:
            _maskView.backgroundColor = [UIColor whiteColor];
            break;
        case MBPopupMaskTypeClear:
            _maskView.backgroundColor = [UIColor clearColor];
            break;
        default: break;
    }
}

- (void)bufferBackground {
    switch (_maskType) {
        case MBPopupMaskTypeBlackBlur:
        case MBPopupMaskTypeWhiteBlur: break;
        case MBPopupMaskTypeBlackTranslucent:
            _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:_maskAlpha - _maskAlpha * 0.15];
            break;
        default: break;
    }
}

- (void)dismissedBackground {
    switch (_maskType) {
        case MBPopupMaskTypeBlackBlur:
        case MBPopupMaskTypeWhiteBlur:
            _maskView.alpha = 0;
            break;
        default:
            _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
            break;
    }
}

#pragma mark - Center point

- (CGPoint)prepareCenterFrom:(NSInteger)type viewRef:(UIView *)viewRef{
    switch (type) {
        case 0: // top
            return CGPointMake(viewRef.center.x,
                               -_popupView.bounds.size.height / 2) ;
        case 1: // bottom
            return CGPointMake(viewRef.center.x,
                               _maskView.bounds.size.height + _popupView.bounds.size.height / 2);
        case 2: // left
            return CGPointMake(-_popupView.bounds.size.width / 2,
                               viewRef.center.y);
        case 3: // right
            return CGPointMake(_maskView.bounds.size.width + _popupView.bounds.size.width / 2,
                               viewRef.center.y);
        default: // center
            return _maskView.center;
    }
}

- (CGPoint)prepareCenter {
    if (_layoutType == MBPopupLayoutTypeCenter) {
        CGPoint point = _maskView.center;
        if (_slideStyle == MBPopupSlideStyleShrinkInOut) {
            _popupView.transform = CGAffineTransformMakeScale(0.15, 0.15);
        } else if (_slideStyle == MBPopupSlideStyleShrinkInGrowOut) {
            _popupView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } else if (_slideStyle == MBPopupSlideStyleFade) {
            _maskView.alpha = 0;
        } else {
            point = [self prepareCenterFrom:_slideStyle viewRef:_maskView];
        }
        return point;
    }
    return [self prepareCenterFrom:_layoutType viewRef:_maskView];
}

- (CGPoint)finishedCenter {
    CGPoint point = _maskView.center;
    switch (_layoutType) {
        case MBPopupLayoutTypeTop:
            return CGPointMake(point.x,
                               _popupView.bounds.size.height / 2);
        case MBPopupLayoutTypeBottom:
            return CGPointMake(point.x,
                               _maskView.bounds.size.height - _popupView.bounds.size.height / 2);
        case MBPopupLayoutTypeLeft:
            return CGPointMake(_popupView.bounds.size.width / 2,
                               point.y);
        case MBPopupLayoutTypeRight:
            return CGPointMake(_maskView.bounds.size.width - _popupView.bounds.size.width / 2,
                               point.y);
        default: // MBPopupLayoutTypeCenter
        {
            if (_slideStyle == MBPopupSlideStyleShrinkInOut ||
                _slideStyle == MBPopupSlideStyleShrinkInGrowOut) {
                _popupView.transform = CGAffineTransformIdentity;
            } else if (_slideStyle == MBPopupSlideStyleFade) {
                _maskView.alpha = 1;
            }
        }
        return point;
    }
}

- (CGPoint)dismissedCenter {
    if (_layoutType != MBPopupLayoutTypeCenter) {
        return [self prepareCenterFrom:_layoutType viewRef:_popupView];
    }
    switch (_slideStyle) {
        case MBPopupSlideStyleFromTop:
            return _dismissOppositeDirection ?
            CGPointMake(_popupView.center.x,
                        _maskView.bounds.size.height + _popupView.bounds.size.height / 2) :
            CGPointMake(_popupView.center.x,
                        -_popupView.bounds.size.height / 2);
            
        case MBPopupSlideStyleFromBottom:
            return _dismissOppositeDirection ?
            CGPointMake(_popupView.center.x,
                        -_popupView.bounds.size.height / 2) :
            CGPointMake(_popupView.center.x,
                        _maskView.bounds.size.height + _popupView.bounds.size.height / 2);
            
        case MBPopupSlideStyleFromLeft:
            return _dismissOppositeDirection ?
            CGPointMake(_maskView.bounds.size.width + _popupView.bounds.size.width / 2,
                        _popupView.center.y) :
            CGPointMake(-_popupView.bounds.size.width / 2,
                        _popupView.center.y);
            
        case MBPopupSlideStyleFromRight:
            return _dismissOppositeDirection ?
            CGPointMake(-_popupView.bounds.size.width / 2,
                        _popupView.center.y) :
            CGPointMake(_maskView.bounds.size.width + _popupView.bounds.size.width / 2,
                        _popupView.center.y);
            
        case MBPopupSlideStyleShrinkInOut:
            _popupView.transform = _dismissOppositeDirection ?
            CGAffineTransformMakeScale(1.75, 1.75) :
            CGAffineTransformMakeScale(0.25, 0.25);
            break;
            
        case MBPopupSlideStyleShrinkInGrowOut:
            _popupView.transform = _dismissOppositeDirection ?
            CGAffineTransformMakeScale(1.2, 1.2) :
            CGAffineTransformMakeScale(0.75, 0.75);
            
        case MBPopupSlideStyleFade:
            _maskView.alpha = 0;
        default: break;
    }
    return _popupView.center;
}

#pragma mark - Buffer point

- (CGPoint)bufferCenter:(CGFloat)move {
    CGPoint point = _popupView.center;
    switch (_layoutType) {
        case MBPopupLayoutTypeTop:
            point.y += move;
            break;
        case MBPopupLayoutTypeBottom:
            point.y -= move;
            break;
        case MBPopupLayoutTypeLeft:
            point.x += move;
            break;
        case MBPopupLayoutTypeRight:
            point.x -= move;
            break;
        case MBPopupLayoutTypeCenter: {
            switch (_slideStyle) {
                case MBPopupSlideStyleFromTop:
                    point.y += _dismissOppositeDirection ? -move : move;
                    break;
                case MBPopupSlideStyleFromBottom:
                    point.y += _dismissOppositeDirection ? move : -move;
                    break;
                case MBPopupSlideStyleFromLeft:
                    point.x += _dismissOppositeDirection ? -move : move;
                    break;
                case MBPopupSlideStyleFromRight:
                    point.x += _dismissOppositeDirection ? move : -move;
                    break;
                case MBPopupSlideStyleShrinkInOut:
                case MBPopupSlideStyleShrinkInGrowOut:
                    _popupView.transform = _dismissOppositeDirection ?
                    CGAffineTransformMakeScale(0.95, 0.95) :
                    CGAffineTransformMakeScale(1.05, 1.05);
                    break;
                default: break;
            }
        } break;
        default: break;
    }
    return point;
}

#pragma mark - Destroy timer

- (void)destroyTimer {
    id value = objc_getAssociatedObject(self, MBPopupViewNSTimerKey);
    if (value) {
        [(NSTimer *)value invalidate];
        objc_setAssociatedObject(self, MBPopupViewNSTimerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark - FrontWindow

- (UIWindow *)frontWindow {
    NSEnumerator *enumerator = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in enumerator) {
        BOOL windowOnMainScreen = (window.screen == [UIScreen mainScreen]);
        BOOL windowIsVisible = !window.isHidden && window.alpha > 0;
        if (windowOnMainScreen && windowIsVisible && window.isKeyWindow) {
            return window;
        }
    }
    UIWindow *applicationWindow = [[UIApplication sharedApplication].delegate window];
    if (!applicationWindow) NSLog(@"** MBPopupView ** Window is nil!");
    return applicationWindow;
}


#pragma mark - Notifications

- (void)bindNotificationEvent {
    [self unbindNotificationEvent];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willChangeStatusBarOrientation)
                                                 name:UIApplicationWillChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeStatusBarOrientation)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)unbindNotificationEvent {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIApplicationWillChangeStatusBarOrientationNotification
                                                 object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIApplicationDidChangeStatusBarOrientationNotification
                                                 object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

#pragma mark - Observing

- (void)keyboardWillChangeFrame:(NSNotification*)notification {
    
    _allowPan = NO; // The pan gesture will be invalid when the keyboard appears.
    
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [_maskView convertRect:keyboardRect fromView:nil];
    CGFloat keyboardHeight = CGRectGetHeight(_maskView.bounds) - CGRectGetMinY(keyboardRect);
    
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationOptions options = curve << 16;
    
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        if (keyboardHeight > 0) {
            
            CGFloat offsetSpacing = self.offsetSpacingOfKeyboard, changeHeight = 0;
            
            switch (self.layoutType) {
                case MBPopupLayoutTypeTop:
                    break;
                case MBPopupLayoutTypeBottom:
                    changeHeight = keyboardHeight + offsetSpacing;
                    break;
                default:
                    changeHeight = (keyboardHeight / 2) + offsetSpacing;
                    break;
            }
            
            if (!CGPointEqualToPoint(CGPointZero, self.markerCenter)) {
                self.popupView.center = CGPointMake(self.markerCenter.x, self.markerCenter.y - changeHeight);
            } else {
                self.popupView.center = CGPointMake(self.popupView.center.x, self.popupView.center.y - changeHeight);
            }
            
        } else {
            if (self.isPresenting) {
                self.popupView.center = [self finishedCenter];
            }
        }
    } completion:^(BOOL finished) {
        self.markerCenter = [self finishedCenter];
    }];
}

- (void)willChangeStatusBarOrientation {
    _maskView.frame = _superview.bounds;
    _popupView.center = [self finishedCenter];
    [self dismiss];
}

- (void)didChangeStatusBarOrientation {
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) { // must manually fix orientation prior to iOS 8
        CGFloat angle;
        switch ([UIApplication sharedApplication].statusBarOrientation)
        {
            case UIInterfaceOrientationPortraitUpsideDown:
                angle = M_PI;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                angle = -M_PI_2;
                break;
            case UIInterfaceOrientationLandscapeRight:
                angle = M_PI_2;
                break;
            default: // as UIInterfaceOrientationPortrait
                angle = 0.0;
                break;
        }
        _popupView.transform = CGAffineTransformMakeRotation(angle);
    }
    _maskView.frame = _superview.bounds;
    _popupView.center = [self finishedCenter];
}

#pragma mark - Gesture Recognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:_popupView]) return NO;
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)g {
    if (_dismissOnMaskTouched) {
        if (!_dropAngle) {
            id object = objc_getAssociatedObject(self, @selector(setSlideStyle:));
            _slideStyle = [object integerValue];
            id obj = objc_getAssociatedObject(self, @selector(setDismissOppositeDirection:));
            _dismissOppositeDirection = [obj boolValue];
        }
        if (nil != self.maskTouched) {
            self.maskTouched(self);
        } else {
            [self dismiss];
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)g {
    if (!_allowPan || !_isPresenting || _dropAngle) {
        return;
    }
    CGPoint translation = [g translationInView:_maskView];
    switch (g.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            switch (_layoutType) {
                case MBPopupLayoutTypeCenter: {
                    
                    BOOL isTransformationVertical = NO;
                    switch (_slideStyle) {
                        case MBPopupSlideStyleFromLeft:
                        case MBPopupSlideStyleFromRight: break;
                        default:
                            isTransformationVertical = YES;
                            break;
                    }
                    
                    NSInteger factor = 4; // set screen ratio `_maskView.bounds.size.height / factor`
                    CGFloat changeValue;
                    if (isTransformationVertical) {
                        g.view.center = CGPointMake(g.view.center.x, g.view.center.y + translation.y);
                        changeValue = g.view.center.y / (_maskView.bounds.size.height / factor);
                    } else {
                        g.view.center = CGPointMake(g.view.center.x + translation.x, g.view.center.y);
                        changeValue = g.view.center.x / (_maskView.bounds.size.width / factor);
                    }
                    CGFloat alpha = factor / 2 - fabs(changeValue - factor / 2);
                    [UIView animateWithDuration:0.15 animations:^{
                        self.maskView.alpha = alpha;
                    } completion:NULL];
                    
                } break;
                case MBPopupLayoutTypeBottom: {
                    if (g.view.frame.origin.y + translation.y > _maskView.bounds.size.height - g.view.bounds.size.height) {
                        g.view.center = CGPointMake(g.view.center.x, g.view.center.y + translation.y);
                    }
                } break;
                case MBPopupLayoutTypeTop: {
                    if (g.view.frame.origin.y + g.view.frame.size.height + translation.y  < g.view.bounds.size.height) {
                        g.view.center = CGPointMake(g.view.center.x, g.view.center.y + translation.y);
                    }
                } break;
                case MBPopupLayoutTypeLeft: {
                    if (g.view.frame.origin.x + g.view.frame.size.width + translation.x < g.view.bounds.size.width) {
                        g.view.center = CGPointMake(g.view.center.x + translation.x, g.view.center.y);
                    }
                } break;
                case MBPopupLayoutTypeRight: {
                    if (g.view.frame.origin.x + translation.x > _maskView.bounds.size.width - g.view.bounds.size.width) {
                        g.view.center = CGPointMake(g.view.center.x + translation.x, g.view.center.y);
                    }
                } break;
                default: break;
            }
            [g setTranslation:CGPointZero inView:_maskView];
        } break;
        case UIGestureRecognizerStateEnded: {
            
            BOOL isWillDismiss = YES, isStyleCentered = NO;
            switch (_layoutType) {
                case MBPopupLayoutTypeCenter: {
                    isStyleCentered = YES;
                    if (g.view.center.y != _maskView.center.y) {
                        if (g.view.center.y > _maskView.bounds.size.height * 0.25 &&
                            g.view.center.y < _maskView.bounds.size.height * 0.75) {
                            isWillDismiss = NO;
                        }
                    } else {
                        if (g.view.center.x > _maskView.bounds.size.width * 0.25 &&
                            g.view.center.x < _maskView.bounds.size.width * 0.75) {
                            isWillDismiss = NO;
                        }
                    }
                } break;
                case MBPopupLayoutTypeBottom:
                    isWillDismiss = g.view.frame.origin.y > _maskView.bounds.size.height - g.view.frame.size.height * 0.75;
                    break;
                case MBPopupLayoutTypeTop:
                    isWillDismiss = g.view.frame.origin.y + g.view.frame.size.height < g.view.frame.size.height * 0.75;
                    break;
                case MBPopupLayoutTypeLeft:
                    isWillDismiss = g.view.frame.origin.x + g.view.frame.size.width < g.view.frame.size.width * 0.75;
                    break;
                case MBPopupLayoutTypeRight:
                    isWillDismiss = g.view.frame.origin.x > _maskView.bounds.size.width - g.view.frame.size.width * 0.75;
                    break;
                default: break;
            }
            if (isWillDismiss) {
                if (isStyleCentered) {
                    switch (_slideStyle) {
                        case MBPopupSlideStyleShrinkInOut:
                        case MBPopupSlideStyleShrinkInGrowOut:
                        case MBPopupSlideStyleFade: {
                            if (g.view.center.y < _maskView.bounds.size.height * 0.25) {
                                _slideStyle = MBPopupSlideStyleFromTop;
                            } else {
                                if (g.view.center.y > _maskView.bounds.size.height * 0.75) {
                                    _slideStyle = MBPopupSlideStyleFromBottom;
                                }
                            }
                            _dismissOppositeDirection = NO;
                        } break;
                        case MBPopupSlideStyleFromTop:
                            _dismissOppositeDirection = !(g.view.center.y < _maskView.bounds.size.height * 0.25);
                            break;
                        case MBPopupSlideStyleFromBottom:
                            _dismissOppositeDirection = g.view.center.y < _maskView.bounds.size.height * 0.25;
                            break;
                        case MBPopupSlideStyleFromLeft:
                            _dismissOppositeDirection = !(g.view.center.x < _maskView.bounds.size.width * 0.25);
                            break;
                        case MBPopupSlideStyleFromRight:
                            _dismissOppositeDirection = g.view.center.x < _maskView.bounds.size.width * 0.25;
                            break;
                        default: break;
                    }
                }
                
                [self dismissWithDuration:0.25f springAnimated:NO];
                
            } else {
                // restore view location.
                id object = objc_getAssociatedObject(self, MBPopupViewParametersKey);
                NSNumber *flagNumber = [object valueForKey:@"MB_springAnimated"];
                BOOL flag = NO;
                if (nil != flagNumber) {
                    flag = flagNumber.boolValue;
                }
                NSTimeInterval duration = 0.25;
                NSNumber* durationNumber = [object valueForKey:@"MB_duration"];
                if (nil != durationNumber) {
                    duration = durationNumber.doubleValue;
                }
                if (flag) {
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveLinear animations:^{
                        g.view.center = [self finishedCenter];
                    } completion:NULL];
                } else {
                    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        g.view.center = [self finishedCenter];
                    } completion:NULL];
                }
            }
            
        } break;
        case UIGestureRecognizerStateCancelled:
            break;
        default: break;
    }
}

- (void)dealloc {
    [self unbindNotificationEvent];
    [self removeSubviews];
}

@end
