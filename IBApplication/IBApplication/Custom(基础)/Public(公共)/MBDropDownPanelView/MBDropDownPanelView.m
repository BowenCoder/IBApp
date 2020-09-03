//
//  MBDropDownPanelView.m
//  IBApplication
//
//  Created by Bowen on 2020/9/3.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBDropDownPanelView.h"

@interface MBDropDownPanelView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, assign) BOOL isDragScroll;

@end

@implementation MBDropDownPanelView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    self.isDragScroll = NO;
    [self addSubview:self.backgroundView];
}

- (void)showContentView:(UIView *)contentView inView:(UIView *)inView
{
    CGSize size = self.frame.size;
    contentView.frame = CGRectMake(0, size.height, size.width, size.height * 3 / 4);
    self.contentView = contentView;
    [self.contentView addGestureRecognizer:self.panGesture];
    [inView addSubview:self];
    [self addSubview:contentView];
    self.backgroundView.alpha = 0.0;
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.backgroundView.alpha = 1.0;
        CGRect frame = self.contentView.frame;
        frame.origin.y = frame.origin.y - frame.size.height;
        self.contentView.frame = frame;
    }
                     completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    self.backgroundView.alpha = 1.0;
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        self.backgroundView.alpha = 0.0;
        CGRect frame = self.contentView.frame;
        frame.origin.y = frame.origin.y + frame.size.height;
        self.contentView.frame = frame;
    }
                     completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Event

- (void)onTapPanelEvent:(UITapGestureRecognizer *)tap
{
    [self dismiss];
}

- (void)onPanContentEvent:(UIPanGestureRecognizer *)pan
{
    CGPoint translation = [pan translationInView:self];
    CGPoint velocity    = [pan velocityInView:self];
    
    switch (pan.state) {
        case UIGestureRecognizerStateChanged: {
            [self panChange:translation];
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded: {
            [self panEnd:translation velocity:velocity];
        } break;
        default:break;
    }
    [pan setTranslation:CGPointZero inView:self.contentView];
}

- (void)panChange:(CGPoint)translation
{
    CGRect frame = self.contentView.frame;
    CGFloat translationY = frame.origin.y + translation.y;
    if (self.isDragScroll) {
        if (self.scrollView.contentOffset.y <= 0) { // scrollView位于顶端
            if (translation.y > 0) { // 向下拖
                self.isDragScroll = NO;
                self.scrollView.contentOffset = CGPointMake(0, 0);
                self.scrollView.panGestureRecognizer.enabled = NO;
                self.scrollView.panGestureRecognizer.enabled = YES;
                self.contentView.frame = CGRectMake(frame.origin.x, translationY, frame.size.width, frame.size.height);
            }
        }
    } else {
        if(translation.y >= 0) { // 向下拖
            self.contentView.frame = CGRectMake(frame.origin.x, translationY, frame.size.width, frame.size.height);
        } else { // 向上拖
            CGFloat endY = self.frame.size.height - frame.size.height;
            if (frame.origin.y > endY) {
                if (translationY <= endY) {
                    translationY = endY;
                }
                self.contentView.frame = CGRectMake(frame.origin.x, translationY, frame.size.width, frame.size.height);
            }
        }
    }
}

- (void)panEnd:(CGPoint)translation velocity:(CGPoint)velocity
{
    if (velocity.y > 1000 && self.scrollView.contentOffset.y == 0) {
        [self dismiss];
    } else {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            CGRect frame = self.contentView.frame;
            frame.origin.y = self.frame.size.height - self.contentView.frame.size.height;
            self.contentView.frame = frame;
        } completion:nil];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(gestureRecognizer == self.panGesture) {
        UIView *touchView = touch.view;
        while (touchView != nil) {
            if([touchView isKindOfClass:[UIScrollView class]]) {
                self.isDragScroll = YES;
                self.scrollView = (UIScrollView *)touchView;
                break;
            } else if(touchView == self.contentView) {
                self.isDragScroll = NO;
                break;
            }
            touchView = (UIView *)[touchView nextResponder];
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if(gestureRecognizer == self.panGesture) {
        if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] || [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")] ) {
            if([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]] ) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - getter

- (UITapGestureRecognizer *)tapGesture {
    if(!_tapGesture){
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapPanelEvent:)];
        _tapGesture.delegate = self;
    }
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if(!_panGesture){
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanContentEvent:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (UIView *)backgroundView {
    if(!_backgroundView){
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
        [_backgroundView addGestureRecognizer:self.tapGesture];
    }
    return _backgroundView;
}

@end
