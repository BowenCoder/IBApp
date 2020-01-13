//
//  MBPopoverView.m
//  IBApplication
//
//  Created by Bowen on 2018/9/20.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBPopupArrowView.h"

@interface MBPopupArrowView ()

@property (nonatomic, assign) CGRect targetRect;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isHiding;
@property (nonatomic, assign) CGPathRef path;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIVisualEffectView *effectView;

@property (nonatomic, weak) UIView *parentView; //引用父视图
@property (nonatomic, weak) UIScrollView *scrollView; //引用滚动视图

@property (nonatomic, copy) dispatch_block_t showsCompletion;
@property (nonatomic, copy) dispatch_block_t hidesCompletion;

@property (nonatomic, readonly) UIView *snapshotView;
@property (nonatomic, readonly) CGSize minSize;
@property (nonatomic, readonly) CGPoint arrowPosition;
@property (nonatomic, readonly) CGPoint animatedFromPoint;
@property (nonatomic, readonly) UIEdgeInsets contentViewInsets;
@property (nonatomic, readonly) MBPopupArrowDirection arrowDirection;

@end

@implementation MBPopupArrowView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (_hideOnTouch&& !_isShowing) {
        if (point.x < 0 || point.y < 0 || point.x > CGRectGetWidth(self.frame) || point.y > CGRectGetHeight(self.frame)) {
            [self hide:YES afterDelay:0.05 completion:nil];
        }
    }
    return hitView;
}

- (void)dealloc {
    [self unregisterScrollView];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    _cornerRadius = 10;
    _arrowCornerRadius = 10;
    _arrowAngle = 90;
    _arrowSize = 10;
    _offsets = CGPointMake(8, 8);
    _arrowDirection = MBPopupArrowDirectionBottom;
    _preferredArrowDirection = MBPopupArrowDirectionAny;
    _priority = MBPopupArrowPriorityVertical;
    _dimBackground = NO;
    _backgroundDrawingColor = [UIColor colorWithRed:0.165f green:0.639f blue:0.937f alpha:1.00f];
    _hideOnTouch = YES;
    _translucent = YES;
    _preferredWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - (self.contentViewInsets.left + self.contentViewInsets.right + self.offsets.x*2);
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];
}


#pragma mark - 显示或者隐藏

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated completion:(dispatch_block_t)completion {
    
    if (_isShowing) return;
    _targetRect = rect;
    _parentView = view;
    if (!_parentView) {
        _parentView = [UIApplication sharedApplication].keyWindow;
    }
    [_parentView addSubview:self.backgroundView];
    [_parentView addSubview:self];
    [self layoutSubviews];
    if (completion) _showsCompletion = [completion copy];
    self.layer.anchorPoint = self.arrowPosition;
    self.transform = CGAffineTransformMakeScale(0.f, 0.f);
    _backgroundView.alpha = 0.0;
    NSTimeInterval animationDutation = animated?0.65:0.0;
    [self viewWillShow:animated];
    [UIView animateWithDuration:animationDutation delay:0.05 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:7 animations:^{
        self.hidden = NO;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (finished) {
            [self viewDidShow:animated];
        }
    }];
    
    if (_dimBackground) {
        [UIView animateWithDuration:0.05 animations:^{
            self.backgroundView.hidden = NO;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateKeyframesWithDuration:0.25 delay:0.0 options:7 animations:^{
                    self.backgroundView.alpha = 1.0;
                } completion:nil];
            }
        }];
    }
}

- (void)hide:(BOOL)animated completion:(dispatch_block_t)completion {
    
    if (_isHiding) return;
    
    if (_scrollView) {
        [self unregisterScrollView];
    }
    
    NSTimeInterval animationDuration = animated?0.25:0.0;
    if (completion) _hidesCompletion = [completion copy];
    [self viewWillHide:animated];
    
    UIView *view;
    if (_translucent) {// using snapshot
        view = self.snapshotView;
        view.frame = self.frame;
        [_parentView addSubview:view];
        self.hidden = YES;
    } else {
        view = self;
    }
    
    [UIView animateWithDuration:animationDuration animations:^{
        view.alpha = 0.0;
        self.backgroundView.alpha = 0.0;
    } completion:NULL];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self viewDidHide:animated];
    });
}

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(dispatch_block_t)completion {
    
    if (completion) {
        _hidesCompletion = [completion copy];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayHideWithOptions:) object:nil];
    [self performSelector:@selector(delayHideWithOptions:) withObject:[NSNumber numberWithBool:animated] afterDelay:delay];
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration {
    __weak typeof(self) weakSelf = self;
    [self showFromRect:rect inView:view animated:animated completion:^{
        [weakSelf hide:animated afterDelay:duration completion:nil];
    }];
}

- (void)showFromView:(UIView *)view inView:(UIView *)aView animated:(BOOL)animated duration:(NSTimeInterval)duration {
    __weak typeof(self) weakSelf = self;
    [self showFromView:view inView:aView animated:animated completion:^{
        [weakSelf hide:animated afterDelay:duration completion:nil];
    }];
}

- (void)showFromView:(UIView *)view inView:(UIView *)aView animated:(BOOL)animated completion:(dispatch_block_t)completion {
    CGRect rect = [aView convertRect:view.frame fromView:view.superview];
    [self showFromRect:rect inView:aView animated:animated completion:completion];
}

- (void)delayHideWithOptions:(NSNumber *)number {
    [self hide:[number boolValue] completion:nil];
}

- (void)viewWillShow:(BOOL)animated {
    _isShowing = YES;
}

- (void)viewDidShow:(BOOL)animated {
    _isShowing = NO;
    if (_showsCompletion) _showsCompletion();
}

- (void)viewWillHide:(BOOL)animated {
    _isHiding = YES;
}

- (void)viewDidHide:(BOOL)animated {
    _isHiding = NO;
    self.alpha = 1.0;
    self.hidden = NO;
    _backgroundView.alpha = 1.0;
    [self setTransform:CGAffineTransformIdentity];
    
    [self setNeedsLayout];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeFromSuperview];
    [self.backgroundView removeFromSuperview];
    if (_hidesCompletion) _hidesCompletion();
}

+ (void)hideVisiblePopoverViewsAnimated:(BOOL)animated fromView:(UIView *)popoverView {
    if (!popoverView) {
        popoverView = [UIApplication sharedApplication].keyWindow;
    }
    
    NSMutableArray *popoverViews = [NSMutableArray array];
    for (UIView *view in popoverView.subviews) {
        if ([view isKindOfClass:[MBPopupArrowView class]]) {
            [popoverViews addObject:view];
        }
    }
    for (UIView *view in popoverView.subviews) {
        if ([view isKindOfClass:[MBPopupArrowView class]]) {
            [popoverViews addObject:view];
        }
    }
    for (MBPopupArrowView *popoverView in popoverViews) {
        [popoverView hide:animated afterDelay:0.0 completion:nil];
    }
}


#pragma mark - Scroll view support
- (void)registerScrollView:(UIScrollView *)scrollView {
    if (_scrollView == scrollView) return;
    [self unregisterScrollView];
    _scrollView = scrollView;
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)unregisterScrollView {
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    self.transform = CGAffineTransformIdentity;
    _scrollView = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint point = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-(point.x + _scrollView.contentInset.left), -(point.y + _scrollView.contentInset.top));
        self.transform = transform;
        
    }
}

#pragma mark - 合成存取

- (UIView *)contentView {
    if (_contentView) return _contentView;
    _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    return _contentView;
}

- (UIView *)backgroundView {
    if(!_backgroundView){
        _backgroundView = [[UIView alloc] initWithFrame:self.parentView.bounds];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        _backgroundView.userInteractionEnabled = YES;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _backgroundView.hidden = YES;
        _backgroundView.alpha = 0.0;
    }
    return _backgroundView;
}

- (UIVisualEffectView *)effectView {
    if (_effectView) return _effectView;
    _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _effectView.frame = self.bounds;
    _effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    return _effectView;
}

- (UIView *)snapshotView {
    UIView *view;
    view = [self.parentView resizableSnapshotViewFromRect:self.frame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = _path;
    view.layer.mask = layer;
    return view;
}

- (CGSize)minSize {
    CGSize size = CGSizeMake(_cornerRadius + 20, _cornerRadius + 20);
    if (_arrowDirection == MBPopupArrowDirectionBottom || _arrowDirection == MBPopupArrowDirectionTop) {
        size.height += _arrowSize;
    } else if (_arrowDirection == MBPopupArrowDirectionLeft || _arrowDirection == MBPopupArrowDirectionRight) {
        size.width += _arrowSize;
    }
    return size;
}

- (UIEdgeInsets)contentViewInsets {
    UIEdgeInsets insets = UIEdgeInsetsMake(_cornerRadius, _cornerRadius, _cornerRadius, _cornerRadius);
    CGFloat topOffsets = 0.0;
    CGFloat leftOffsets = 0.0;
    CGFloat bottomOffsets = 0.0;
    CGFloat rightOffsets = 0.0;
    switch (_arrowDirection) {
        case MBPopupArrowDirectionTop:
            topOffsets = _arrowSize;
            break;
        case MBPopupArrowDirectionLeft:
            leftOffsets = _arrowSize;
            break;
        case MBPopupArrowDirectionBottom:
            bottomOffsets = _arrowSize;
            break;
        case MBPopupArrowDirectionRight:
            rightOffsets = _arrowSize;
            break;
        default:
            break;
    }
    insets.top += topOffsets;
    insets.left += leftOffsets;
    insets.bottom += bottomOffsets;
    insets.right += rightOffsets;
    return insets;
}

- (CGPoint)animatedFromPoint {
    CGRect originalFrame = CGRectMake(0, 0, 0, 0);
    MBPopupArrowDirection direction = [self directionWithRect:_targetRect];
    switch (direction) {
        case MBPopupArrowDirectionBottom:
            originalFrame.origin.x = CGRectGetMidX(_targetRect);
            originalFrame.origin.y = CGRectGetMinY(_targetRect);
            break;
        case MBPopupArrowDirectionLeft:
            originalFrame.origin.x = CGRectGetMaxX(_targetRect);
            originalFrame.origin.y = CGRectGetMidY(_targetRect);
            break;
        case MBPopupArrowDirectionRight:
            originalFrame.origin.x = CGRectGetMinX(_targetRect);
            originalFrame.origin.y = CGRectGetMidY(_targetRect);
            break;
        case MBPopupArrowDirectionTop:
            originalFrame.origin.x = CGRectGetMidX(_targetRect);
            originalFrame.origin.y = CGRectGetMaxY(_targetRect);
            break;
        default:
            break;
    }
    return originalFrame.origin;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsDisplay];
}

- (void)setArrowAngle:(CGFloat)arrowAngle {
    _arrowAngle = arrowAngle;
    [self setNeedsDisplay];
}

- (void)setArrowSize:(CGFloat)arrowSize {
    _arrowSize = arrowSize;
    [self setNeedsDisplay];
}

- (void)setArrowCornerRadius:(CGFloat)arrowCornerRadius {
    _arrowCornerRadius = arrowCornerRadius;
    [self setNeedsDisplay];
}

- (void)setArrowDirection:(MBPopupArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
    [self setNeedsDisplay];
}

- (void)setPriority:(MBPopupArrowPriority)priority {
    _priority = priority;
    [self setNeedsDisplay];
}

///消除背景色影响
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
}

- (void)setBackgroundDrawingColor:(UIColor *)backgroundDrawingColor {
    _backgroundDrawingColor = backgroundDrawingColor;
    [self setNeedsDisplay];
}

- (void)setTranslucent:(BOOL)translucent {
    _translucent = translucent;
    
    if (translucent) {
        [self insertSubview:self.effectView atIndex:0];
        [self.effectView.contentView addSubview:_contentView];
        [self addSubview:_contentView];
    } else {
        [self.effectView removeFromSuperview];
        [self addSubview:_contentView];
    }
    [self setNeedsDisplay];
}

- (void)setTranslucentStyle:(MBPopupArrowStyle)translucentStyle {
    _translucentStyle = translucentStyle;
    switch (_translucentStyle) {
        case MBPopupArrowStyleLight:
            _effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            break;
        default:
            _effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            break;
    }
}

- (void)setPreferredWidth:(CGFloat)preferredWidth {
    _preferredWidth = preferredWidth;
    [self setNeedsLayout];
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    UIEdgeInsets contentInsets = self.contentViewInsets;
    CGRect contentFrame = CGRectZero;
    contentFrame.origin.x = contentInsets.left;
    contentFrame.origin.y = contentInsets.top;
    contentFrame.size.height = self.frame.size.height - contentInsets.top - contentInsets.bottom;
    contentFrame.size.width = self.frame.size.width - contentInsets.left - contentInsets.right;
    self.contentView.frame = contentFrame;
    [self updateFrameWithRect:self.targetRect];
}

- (MBPopupArrowDirection)directionWithRect:(CGRect)rect {
    UIEdgeInsets margins = UIEdgeInsetsMake(rect.origin.y, rect.origin.x, self.parentView.bounds.size.height - CGRectGetMaxY(rect), self.parentView.bounds.size.width - CGRectGetMaxX(rect));
    NSMutableArray *availableDirections = [NSMutableArray array];
    if (_priority == MBPopupArrowPriorityHorizontal) {
        CGFloat margin=.0;
        if (margins.left >= CGRectGetWidth(self.bounds)) {// Show on left.
            [availableDirections addObject:@(MBPopupArrowDirectionRight)];
            margin = margins.left;
        } if (margins.right >= CGRectGetWidth(self.bounds)) {// Show on right.
            if (margins.right >= margin) {
                [availableDirections insertObject:@(MBPopupArrowDirectionLeft) atIndex:0];
            } else {
                [availableDirections addObject:@(MBPopupArrowDirectionLeft)];
            }
            margin = margins.right;
        } if (margins.top >= CGRectGetHeight(self.bounds)) {// Show on top.
            if (margins.top >= margin) {
                [availableDirections insertObject:@(MBPopupArrowDirectionBottom) atIndex:0];
            } else {
                [availableDirections addObject:@(MBPopupArrowDirectionBottom)];
            }
            margin = margins.top;
        } if (margins.bottom >= CGRectGetHeight(self.bounds)) {// Show on bottom.
            if (margins.bottom >= margin) {
                [availableDirections insertObject:@(MBPopupArrowDirectionTop) atIndex:0];
            } else {
                [availableDirections addObject:@(MBPopupArrowDirectionTop)];
            }
        }
    } else {
        CGFloat margin=.0;
        if (margins.top >= CGRectGetHeight(self.bounds)) {// Show on top.
            if (margins.top >= margin) {
                [availableDirections insertObject:@(MBPopupArrowDirectionBottom) atIndex:0];
            } else {
                [availableDirections addObject:@(MBPopupArrowDirectionBottom)];
            }
            margin = margins.top;
        } if (margins.bottom >= CGRectGetHeight(self.bounds)) {// Show on bottom.
            if (margins.bottom >= margin) {
                [availableDirections insertObject:@(MBPopupArrowDirectionTop) atIndex:0];
            } else {
                [availableDirections addObject:@(MBPopupArrowDirectionTop)];
            }
            margin = margins.bottom;
        } if (margins.left >= CGRectGetWidth(self.bounds)) {// Show on left.
            if (margins.left >= margin) {
                [availableDirections insertObject:@(MBPopupArrowDirectionRight) atIndex:0];
            } else {
                [availableDirections addObject:@(MBPopupArrowDirectionRight)];
            }
            margin = margins.left;
        } if (margins.right >= CGRectGetWidth(self.bounds)) {// Show on right.
            if (margins.right >= margin) {
                [availableDirections insertObject:@(MBPopupArrowDirectionLeft) atIndex:0];
            } else {
                [availableDirections addObject:@(MBPopupArrowDirectionLeft)];
            }
        }
    }
    if (availableDirections.count > 0) {
        if (_preferredArrowDirection != MBPopupArrowDirectionAny) {
            if ([availableDirections containsObject:@(_preferredArrowDirection)]) {
                return _preferredArrowDirection;
            } else
                return [[availableDirections firstObject] integerValue];
        } else
            return [[availableDirections firstObject] integerValue];
    }
    return MBPopupArrowDirectionAny;
}

- (void)updateFrameWithRect:(CGRect)rct {
    CGRect rect = self.frame;
    MBPopupArrowDirection direction = [self directionWithRect:rct];
    _arrowDirection = direction;
    if (direction == MBPopupArrowDirectionBottom || direction == MBPopupArrowDirectionTop) {
        if (direction == MBPopupArrowDirectionBottom) {
            rect.origin.y = CGRectGetMinY(rct) - CGRectGetHeight(rect);
            _arrowPosition.y = 1;
        } else {
            rect.origin.y = CGRectGetMaxY(rct);
            _arrowPosition.y = 0;
        }
        if (CGRectGetMidX(rct) >= CGRectGetWidth(rect)/2 + _offsets.x && CGRectGetWidth(self.parentView.bounds) - CGRectGetMidX(rct) >= CGRectGetWidth(rect)/2 + _offsets.x) {
            // arrow in the middle
            _arrowPosition.x = .5;
            rect.origin.x = (CGRectGetWidth(rct) - CGRectGetWidth(rect))/2 + rct.origin.x;
        } else if (CGRectGetMidX(rct) < CGRectGetWidth(rect)/2 + _offsets.x) {
            // arrow in the middle left
            rect.origin.x = _offsets.x;
            _arrowPosition.x = (CGRectGetMidX(rct) - _offsets.x)/CGRectGetWidth(rect);
        } else if (CGRectGetWidth(self.parentView.bounds) - CGRectGetMidX(rct) < CGRectGetWidth(rect)/2 + _offsets.x) {
            // arrow in the middle right
            rect.origin.x = CGRectGetWidth(self.parentView.bounds) - (CGRectGetWidth(rect) + _offsets.x);
            _arrowPosition.x = (CGRectGetWidth(rect) - (CGRectGetWidth(self.parentView.bounds) - CGRectGetMidX(rct) - _offsets.x))/CGRectGetWidth(rect);
        }
    } else if (direction == MBPopupArrowDirectionLeft | direction == MBPopupArrowDirectionRight) {
        if (direction == MBPopupArrowDirectionRight) {
            rect.origin.x = CGRectGetMinX(rct) - CGRectGetWidth(rect);
            _arrowPosition.x = 1;
        } else {
            rect.origin.x = CGRectGetMaxX(rct);
            _arrowPosition.x = 0;
        }
        if (CGRectGetMidY(rct) >= CGRectGetHeight(rect)/2 + _offsets.y && CGRectGetHeight(self.parentView.bounds) - CGRectGetMidY(rct) >= CGRectGetHeight(rect)/2 + _offsets.y) {
            // arrow in the middle
            _arrowPosition.y = .5;
            rect.origin.y = (CGRectGetHeight(rct) - CGRectGetHeight(rect))/2 + rct.origin.y;
        } else if (CGRectGetMidY(rct) < CGRectGetWidth(rect)/2 + _offsets.y) {
            // arrow in the middle top
            rect.origin.y = _offsets.y;
            _arrowPosition.y = (CGRectGetMidY(rct) - _offsets.y)/CGRectGetHeight(rect);
        } else if (CGRectGetHeight(self.parentView.bounds) - CGRectGetMidY(rct) < CGRectGetHeight(rect)/2 + _offsets.y) {
            // arrow in the middle bottom
            rect.origin.y = CGRectGetHeight(self.parentView.bounds) - (CGRectGetHeight(rect) + _offsets.y);
            _arrowPosition.y = (CGRectGetHeight(rect) - (CGRectGetHeight(self.parentView.bounds) - CGRectGetMidY(rct) - _offsets.y))/CGRectGetHeight(rect);
        }
    }
    [self setNeedsDisplay];
    self.frame = rect;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code
    // bubble Drawing
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    if (!cxt) {
        return;
    }
    CGContextSetFillColorWithColor(cxt, _backgroundDrawingColor.CGColor);
    CGContextSetLineWidth(cxt, 3.0);
    // top line drawing
    
    CGFloat topOffsets = 0.;
    CGFloat leftOffsets = 0.;
    CGFloat bottomOffsets = 0.;
    CGFloat rightOffsets = 0.;
    switch (self.arrowDirection) {
        case MBPopupArrowDirectionTop:
            topOffsets = _arrowSize;
            break;
        case MBPopupArrowDirectionLeft:
            leftOffsets = _arrowSize;
            break;
        case MBPopupArrowDirectionBottom:
            bottomOffsets = _arrowSize;
            break;
        case MBPopupArrowDirectionRight:
            rightOffsets = _arrowSize;
            break;
        default:
            break;
    }
    // the origin point
    CGContextMoveToPoint(cxt, CGRectGetMinX(rect) + _cornerRadius + leftOffsets, CGRectGetMinY(rect) + topOffsets);
    if (_arrowDirection == MBPopupArrowDirectionTop) {
        [self addTopArrowPointWithContext:cxt arrowAngle:_arrowAngle arrowHeight:_arrowSize arrowPositionX:CGRectGetWidth(rect)*_arrowPosition.x];
    }
    CGContextAddLineToPoint(cxt, CGRectGetMaxX(rect) - _cornerRadius - rightOffsets, CGRectGetMinY(rect) + topOffsets);
    // top right arc drawing
    CGContextAddArcToPoint(cxt, CGRectGetMaxX(rect) - rightOffsets, CGRectGetMinY(rect) + topOffsets, CGRectGetMaxX(rect) - rightOffsets, CGRectGetMinY(rect) + _cornerRadius + topOffsets, _cornerRadius);
    if (_arrowDirection == MBPopupArrowDirectionRight) {
        [self addRightArrowPointWithContext:cxt arrowAngle:_arrowAngle arrowWidth:_arrowSize arrowPositionY:CGRectGetHeight(rect)*_arrowPosition.y];
    }
    // right line drawing
    CGContextAddLineToPoint(cxt, CGRectGetMaxX(rect) - rightOffsets, CGRectGetMaxY(rect) - _cornerRadius - bottomOffsets);
    // bottom right arc drawing
    CGContextAddArcToPoint(cxt, CGRectGetMaxX(rect) - rightOffsets, CGRectGetMaxY(rect) - bottomOffsets, CGRectGetMaxX(rect) - _cornerRadius - rightOffsets, CGRectGetMaxY(rect) - bottomOffsets, _cornerRadius);
    // bottom line drawing
    if (_arrowDirection == MBPopupArrowDirectionBottom) {
        [self addBottomArrowPointWithContext:cxt arrowAngle:_arrowAngle arrowHeight:_arrowSize arrowPositionX:CGRectGetWidth(rect)*_arrowPosition.x];
    }
    CGContextAddLineToPoint(cxt, CGRectGetMinX(rect) + _cornerRadius + leftOffsets, CGRectGetMaxY(rect) - bottomOffsets);
    // bottom left arc drawing
    CGContextAddArcToPoint(cxt, CGRectGetMinX(rect) + leftOffsets, CGRectGetMaxY(rect) - bottomOffsets, CGRectGetMinX(rect) + leftOffsets, CGRectGetMaxY(rect) - _cornerRadius - bottomOffsets, _cornerRadius);
    if (_arrowDirection == MBPopupArrowDirectionLeft) {
        [self addLeftArrowPointWithContext:cxt arrowAngle:_arrowAngle arrowWidth:_arrowSize arrowPositionY:CGRectGetHeight(rect)*_arrowPosition.y];
    }
    // left line drawing
    CGContextAddLineToPoint(cxt, CGRectGetMinX(rect) + leftOffsets, CGRectGetMinY(rect) + _cornerRadius + topOffsets);
    // top left arc drawing
    CGContextAddArcToPoint(cxt, CGRectGetMinX(rect) + leftOffsets, CGRectGetMinY(rect) + topOffsets, CGRectGetMinX(rect) + _cornerRadius + leftOffsets, CGRectGetMinY(rect) + topOffsets, _cornerRadius);
    if (_translucent) {
        _path = CGContextCopyPath(cxt);
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = _path;
        _effectView.layer.mask = maskLayer;
    } else {
        CGContextFillPath(cxt);
    }
}

- (void)addTopArrowPointWithContext:(CGContextRef)cxt arrowAngle:(CGFloat)angle arrowHeight:(CGFloat)height arrowPositionX:(CGFloat)x {
    if (!cxt) {
        return;
    }
    CGFloat arrowWidth_2 = height * tan(angle*M_PI/360);
    CGFloat constant = _arrowCornerRadius * tan((45-(angle/4))*M_PI/180);
    CGFloat constantX = constant*sin(angle*M_PI/360);
    CGFloat constantY = constant*cos(angle*M_PI/360);
    CGFloat xConstant = x - arrowWidth_2;
    if (xConstant < 0) return;
    if (xConstant - constant < _cornerRadius) {
        CGContextAddLineToPoint(cxt, MAX(xConstant, _cornerRadius), CGRectGetMinY(self.bounds) + height);
    } else {
        CGContextAddLineToPoint(cxt, xConstant - constant, CGRectGetMinY(self.bounds) + height);
        CGContextAddArcToPoint(cxt, xConstant, CGRectGetMinY(self.bounds) + height, xConstant + constantX, CGRectGetMinY(self.bounds) + height - constantY, _arrowCornerRadius);
    }
    CGContextAddLineToPoint(cxt, x, CGRectGetMinY(self.bounds));
    xConstant = x + arrowWidth_2;
    if (xConstant > CGRectGetMaxX(self.bounds)) return;
    if (xConstant + constant > CGRectGetWidth(self.bounds) - _cornerRadius) {
        CGContextAddLineToPoint(cxt, MIN(xConstant, CGRectGetWidth(self.bounds) - _cornerRadius), CGRectGetMinY(self.bounds) + height);
    } else {
        CGContextAddLineToPoint(cxt, xConstant - constantX, CGRectGetMinY(self.bounds) + height - constantY);
        CGContextAddArcToPoint(cxt, xConstant, CGRectGetMinY(self.bounds) + height, xConstant + constant, CGRectGetMinY(self.bounds) + height, _arrowCornerRadius);
    }
}

- (void)addBottomArrowPointWithContext:(CGContextRef)cxt arrowAngle:(CGFloat)angle arrowHeight:(CGFloat)height arrowPositionX:(CGFloat)x {
    if (!cxt) {
        return;
    }
    CGFloat arrowWidth_2 = height * tan(angle*M_PI/360);
    CGFloat constant = _arrowCornerRadius * tan((45-(angle/4))*M_PI/180);
    CGFloat constantX = constant*sin(angle*M_PI/360);
    CGFloat constantY = constant*cos(angle*M_PI/360);
    CGFloat xConstant = x + arrowWidth_2;
    if (xConstant > CGRectGetMaxX(self.bounds)) return;
    if (xConstant + constant > CGRectGetWidth(self.bounds) - _cornerRadius) {
        CGContextAddLineToPoint(cxt, MIN(xConstant, CGRectGetWidth(self.bounds) - _cornerRadius), CGRectGetMaxY(self.bounds) - height);
    } else {
        CGContextAddLineToPoint(cxt, xConstant + constant, CGRectGetMaxY(self.bounds) - height);
        CGContextAddArcToPoint(cxt, xConstant, CGRectGetMaxY(self.bounds) - height, xConstant - constantX, CGRectGetMaxY(self.bounds) - height + constantY, _arrowCornerRadius);
    }
    CGContextAddLineToPoint(cxt, x, CGRectGetMaxY(self.bounds));
    xConstant = x - arrowWidth_2;
    if (xConstant < 0) return;
    if (xConstant - constant < _cornerRadius) {
        CGContextAddLineToPoint(cxt, MAX(xConstant, _cornerRadius), CGRectGetMaxY(self.bounds) - height);
    } else {
        CGContextAddLineToPoint(cxt, xConstant + constantX, CGRectGetMaxY(self.bounds) - height + constantY);
        CGContextAddArcToPoint(cxt, xConstant, CGRectGetMaxY(self.bounds) - height, xConstant - constant, CGRectGetMaxY(self.bounds) - height, _arrowCornerRadius);
    }
}

- (void)addLeftArrowPointWithContext:(CGContextRef)cxt arrowAngle:(CGFloat)angle arrowWidth:(CGFloat)width arrowPositionY:(CGFloat)y {
    
    if (!cxt) {
        return;
    }
    CGFloat arrowHtight_2 = width * tan(angle*M_PI/360);
    CGFloat constant = _arrowCornerRadius * tan((45-(angle/4))*M_PI/180);
    CGFloat constantY = constant*sin(angle*M_PI/360);
    CGFloat constantX = constant*cos(angle*M_PI/360);
    CGFloat Yconstant = y + arrowHtight_2;
    if (Yconstant > CGRectGetMaxY(self.bounds)) return;
    if (Yconstant + constant > CGRectGetHeight(self.bounds) - _cornerRadius) {
        CGContextAddLineToPoint(cxt, CGRectGetMinX(self.bounds) + width, MIN(Yconstant, CGRectGetHeight(self.bounds) - _cornerRadius));
    } else {
        CGContextAddLineToPoint(cxt, CGRectGetMinX(self.bounds) + width, Yconstant + constant);
        CGContextAddArcToPoint(cxt, CGRectGetMinX(self.bounds) + width, Yconstant, CGRectGetMinX(self.bounds) + width - constantX, Yconstant - constantY, _arrowCornerRadius);
    }
    CGContextAddLineToPoint(cxt, CGRectGetMinX(self.bounds), y);
    Yconstant = y - arrowHtight_2;
    if (Yconstant < 0) return;
    if (Yconstant - constant < _cornerRadius) {
        CGContextAddLineToPoint(cxt, CGRectGetMinX(self.bounds) + width, MAX(Yconstant, _cornerRadius));
    } else {
        CGContextAddLineToPoint(cxt, CGRectGetMinX(self.bounds) + width - constantX, y - arrowHtight_2 + constantY);
        CGContextAddArcToPoint(cxt, CGRectGetMinX(self.bounds) + width, Yconstant, CGRectGetMinX(self.bounds) + width, Yconstant - constant, _arrowCornerRadius);
    }
}

- (void)addRightArrowPointWithContext:(CGContextRef)cxt arrowAngle:(CGFloat)angle arrowWidth:(CGFloat)width arrowPositionY:(CGFloat)y {
    
    if (!cxt) {
        return;
    }
    CGFloat arrowHtight_2 = width * tan(angle*M_PI/360);
    CGFloat constant = _arrowCornerRadius * tan((45-(angle/4))*M_PI/180);
    CGFloat constantY = constant*sin(angle*M_PI/360);
    CGFloat constantX = constant*cos(angle*M_PI/360);
    CGFloat Yconstant = y - arrowHtight_2;
    if (Yconstant < 0) return;
    if (Yconstant - constant < _cornerRadius) {
        CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds) - width, MAX(Yconstant, _cornerRadius));
    } else {
        CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds) - width, Yconstant - constant);
        CGContextAddArcToPoint(cxt, CGRectGetMaxX(self.bounds) - width, Yconstant, CGRectGetMaxX(self.bounds) - width + constantX, Yconstant + constantY, _arrowCornerRadius);
    }
    CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds), y);
    Yconstant = y + arrowHtight_2;
    if (Yconstant > CGRectGetMaxY(self.bounds)) return;
    if (Yconstant + constant > CGRectGetHeight(self.bounds) - _cornerRadius) {
        CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds) - width, MIN(Yconstant, CGRectGetHeight(self.bounds) - _cornerRadius));
    } else {
        CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds) - width + constantX, Yconstant - constantY);
        CGContextAddArcToPoint(cxt, CGRectGetMaxX(self.bounds) - width, Yconstant, CGRectGetMaxX(self.bounds) - width, Yconstant + constant, _arrowCornerRadius);
    }
}

@end
