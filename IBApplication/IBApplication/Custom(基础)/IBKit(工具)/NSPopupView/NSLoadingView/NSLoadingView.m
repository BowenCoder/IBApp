//
//  NSLoadingView.m
//  IBApplication
//
//  Created by Bowen on 2018/7/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSLoadingView.h"

#define margin 15

@interface NSLoadingView () <CAAnimationDelegate>

@property (nonatomic, strong) CALayer *redLayer;
@property (nonatomic, strong) CALayer *yellowLayer;
@property (nonatomic, strong) CALayer *blueLayer;
@property (nonatomic, strong) CALayer *containerLayer;
@property (nonatomic, strong) NSMutableArray<CALayer *> *balls;
@property (nonatomic, assign) BOOL evenRun;
@end

@implementation NSLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _evenRun = NO;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    CGFloat cx = self.frame.size.width/2 - 60;
    CGFloat cy = self.frame.size.height/2 - 30;
    CGFloat cw = 120;
    CGFloat ch = 60;
    self.containerLayer = [CALayer layer];
    self.containerLayer.frame = CGRectMake(cx, cy, cw, ch);
    self.containerLayer.backgroundColor =[UIColor lightGrayColor].CGColor;
    [self.layer addSublayer:self.containerLayer];
    
    CGFloat bx = cw/2 - 18 - margin;
    CGFloat by = ch/2 - 6;
    CGFloat bw = 12;
    CGFloat bh = 12;
    self.blueLayer = [CALayer layer];
    self.blueLayer.frame = CGRectMake(bx, by, bw, bh);
    self.blueLayer.cornerRadius = 6;
    self.blueLayer.backgroundColor = [UIColor colorWithRed:102.f/255 green:201.f/255 blue:255.f/255 alpha:1.0].CGColor;
    [self.containerLayer addSublayer:self.blueLayer];
    
    CGFloat rx = cw/2 - 6;
    CGFloat ry = ch/2 - 6;
    CGFloat rw = 12;
    CGFloat rh = 12;
    self.redLayer = [CALayer layer];
    self.redLayer.frame = CGRectMake(rx, ry, rw, rh);
    self.redLayer.cornerRadius = 6;
    self.redLayer.backgroundColor = [UIColor colorWithRed:252.f/255 green:79.f/255 blue:74.f/255 alpha:1.0].CGColor;
    [self.containerLayer addSublayer:self.redLayer];

    CGFloat yx = cw/2 + 6 + margin;
    CGFloat yy = ch/2 - 6;
    CGFloat yw = 12;
    CGFloat yh = 12;
    self.yellowLayer = [CALayer layer];
    self.yellowLayer.frame = CGRectMake(yx, yy, yw, yh);
    self.yellowLayer.cornerRadius = 6;
    self.yellowLayer.backgroundColor = [UIColor colorWithRed:254.f/255 green:212.f/255 blue:31.f/255 alpha:1.0].CGColor;
    [self.containerLayer addSublayer:self.yellowLayer];
    
    self.balls = @[self.blueLayer, self.redLayer, self.yellowLayer].mutableCopy;
    
}

- (void)changeBalls {
    
    if (self.evenRun) {
        [self.balls exchangeObjectAtIndex:0 withObjectAtIndex:1];
    } else {
        [self.balls exchangeObjectAtIndex:1 withObjectAtIndex:2];
    }
}


- (void)startAnimation {
    
    NSInteger index;
    if (self.evenRun) {
        index = 1;
        self.evenRun = NO;
    } else {
        index = 0;
        self.evenRun = YES;
    }
    
    CALayer *firstLayer = self.balls[index];
    CALayer *secondLayer = self.balls[index+1];
    
    CGFloat radius = (secondLayer.position.x - firstLayer.position.x)/2;
    CGFloat tx = firstLayer.frame.origin.x + radius + 6;
    CGFloat ty = self.containerLayer.frame.size.height/2;

    UIBezierPath *topPath = [UIBezierPath bezierPath];
    [topPath moveToPoint:firstLayer.position];
    [topPath addArcWithCenter:CGPointMake(tx, ty) radius:radius startAngle:M_PI endAngle:M_PI*2 clockwise:YES];
    [topPath moveToPoint:secondLayer.position];

    CAKeyframeAnimation *topAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    topAnimation.path = topPath.CGPath;
    topAnimation.removedOnCompletion = NO;
    topAnimation.fillMode = kCAFillModeBoth;
    topAnimation.duration = 1;
    topAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [firstLayer.presentationLayer addAnimation:topAnimation forKey:@"topAnimation"];
    
    UIBezierPath *bottomPath = [UIBezierPath bezierPath];
    [bottomPath moveToPoint:secondLayer.position];
    [bottomPath addArcWithCenter:CGPointMake(tx, ty) radius:radius startAngle:0 endAngle:M_PI clockwise:YES];
    [bottomPath moveToPoint:firstLayer.position];
    
    CAKeyframeAnimation *bottomAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    bottomAnimation.delegate = self;
    bottomAnimation.path = bottomPath.CGPath;
    bottomAnimation.removedOnCompletion = NO;
    bottomAnimation.fillMode = kCAFillModeBoth;
    bottomAnimation.duration = 1;
    bottomAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [secondLayer.presentationLayer addAnimation:bottomAnimation forKey:@"bottomAnimation"];
    
}

- (void)animationDidStart:(CAAnimation *)anim {
    NSLog(@"animationDidStart");
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"animationDidStop");
    
    NSInteger index;
    if (self.evenRun) {
        index = 0;
    } else {
        index = 1;
    }
    
    CGPoint position;
    CALayer *first = self.balls[index];
    CALayer *sencond = self.balls[index +1];
    position = sencond.position;
    sencond.position = first.position;
    first.position = position;
    
    [self changeBalls];

    [self startAnimation];
}

- (void)stopAnimation {

}


@end
