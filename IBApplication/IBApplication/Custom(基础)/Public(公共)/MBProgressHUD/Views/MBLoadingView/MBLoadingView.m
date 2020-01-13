//
//  MBLoadingView.m
//  IBApplication
//
//  Created by Bowen on 2018/7/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBLoadingView.h"

#define margin 12

@interface MBBallLoadingView () <CAAnimationDelegate>

@property (nonatomic, strong) CALayer *redLayer;
@property (nonatomic, strong) CALayer *yellowLayer;
@property (nonatomic, strong) CALayer *blueLayer;
@property (nonatomic, strong) CALayer *containerLayer;
@property (nonatomic, strong) NSMutableArray<CALayer *> *balls;
@property (nonatomic, assign) BOOL evenRun;//偶数次运行

@end

@implementation MBBallLoadingView

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (instancetype)init {
    
    if(self = [super init]) {
        _evenRun = NO;
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
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

void resetData(MBBallLoadingView *obj,CALayer **firstLayer, CALayer **secondLayer, float *radius, CGPoint *point) {
    
    CGFloat tx, ty;
    *radius = (obj.redLayer.position.x - obj.blueLayer.position.x)/2;
    ty =  obj.containerLayer.frame.size.height/2;
    
    if (obj.evenRun) {
        obj.evenRun = NO;
        *firstLayer = obj.balls[1];
        *secondLayer = obj.balls[2];
        tx = obj.redLayer.frame.origin.x + *radius + 6;
        [obj.balls exchangeObjectAtIndex:1 withObjectAtIndex:2];

    } else {
        obj.evenRun = YES;
        *firstLayer = obj.balls[0];
        *secondLayer = obj.balls[1];
        tx = obj.blueLayer.frame.origin.x + *radius + 6;
        [obj.balls exchangeObjectAtIndex:0 withObjectAtIndex:1];
    }
    *point = CGPointMake(tx, ty);
}

- (void)startAnimation {
    if (self.isAnimating) {
        return;
    }
    self.isAnimating = YES;
    CALayer *firstLayer, *secondLayer;
    float radius;
    CGPoint center;
    resetData(self ,&firstLayer, &secondLayer, &radius, &center);

    UIBezierPath *firstPath = [UIBezierPath bezierPath];
    [firstPath addArcWithCenter:center radius:radius startAngle:M_PI endAngle:M_PI*2 clockwise:YES];
    CAKeyframeAnimation *firstAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    firstAnimation.path = firstPath.CGPath;
    firstAnimation.removedOnCompletion = NO;
    firstAnimation.fillMode = kCAFillModeBoth;
    firstAnimation.duration = 0.5;
    firstAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [firstLayer addAnimation:firstAnimation forKey:@"firstAnimation"];
    
    UIBezierPath *secondPath = [UIBezierPath bezierPath];
    [secondPath addArcWithCenter:center radius:radius startAngle:0 endAngle:M_PI clockwise:YES];
    CAKeyframeAnimation *secondAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    secondAnimation.delegate = self;
    secondAnimation.path = secondPath.CGPath;
    secondAnimation.removedOnCompletion = NO;
    secondAnimation.fillMode = kCAFillModeBoth;
    secondAnimation.duration = 0.5;
    secondAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [secondLayer addAnimation:secondAnimation forKey:@"secondAnimation"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startAnimation];
    });
}

- (void)stopAnimation {
    self.isAnimating = NO;
    [self.blueLayer removeAllAnimations];
    [self.redLayer removeAllAnimations];
    [self.yellowLayer removeAllAnimations];
}

@end

@interface MBCircleLoadingView ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAAnimationGroup *strokeLineAnimation;
@property (nonatomic, strong) CAAnimation *rotationAnimation;
@property (nonatomic, strong) CAAnimation *strokeColorAnimation;

@end

@implementation MBCircleLoadingView

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (instancetype)init {
    
    if(self = [super init]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.backgroundColor = [UIColor whiteColor];
    self.circleLayer = [CAShapeLayer layer];
    CGFloat cx = self.frame.size.width/2 - 20;
    CGFloat cy = self.frame.size.height/2 - 20;
    CGFloat cw = 40;
    CGFloat ch = 40;
    self.circleLayer.frame = CGRectMake(cx, cy, cw, ch);
    self.circleLayer.fillColor = nil;
    self.circleLayer.lineWidth = 2.0;
    self.circleLayer.lineCap = kCALineCapRound;
    
    CGPoint center = CGPointMake(cw/2.0, ch/2.0);
    CGFloat radius = cw/2.0 - self.circleLayer.lineWidth/2.0;
    CGFloat startAngle = 0;
    CGFloat endAngle = 2*M_PI;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:startAngle
                                                      endAngle:endAngle
                                                     clockwise:YES];
    self.circleLayer.path = path.CGPath;
    [self.layer addSublayer:self.circleLayer];
    
    self.colorArray = @[[UIColor redColor]].mutableCopy;
}

- (void)setColorArray:(NSMutableArray *)colorArray{
    _colorArray = [NSMutableArray array];
    if (colorArray.count > 0) {
        for (UIColor *color in colorArray) {
            [_colorArray addObject:(id)color.CGColor];
        }
    }
    [self updateAnimations];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    self.circleLayer.lineWidth = _lineWidth;
}

- (void)updateAnimations {
    // Stroke Head
    CABasicAnimation *headAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    headAnimation.beginTime = 0.5;
    headAnimation.fromValue = @0;
    headAnimation.toValue = @1;
    headAnimation.duration = 1.0;
    headAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // Stroke Tail
    CABasicAnimation *tailAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    tailAnimation.fromValue = @0;
    tailAnimation.toValue = @1;
    tailAnimation.duration = 1.0;
    tailAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // Stroke Line Group
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 1.5;
    animationGroup.repeatCount = INFINITY;
    animationGroup.animations = @[headAnimation, tailAnimation];
    self.strokeLineAnimation = animationGroup;
    
    // Rotation
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = @0;
    rotationAnimation.toValue = @(2*M_PI);
    rotationAnimation.duration = 1.5;
    rotationAnimation.repeatCount = INFINITY;
    self.rotationAnimation = rotationAnimation;
    
    CAKeyframeAnimation *strokeColorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"strokeColor"];
    strokeColorAnimation.values = self.colorArray;
    strokeColorAnimation.keyTimes = [self prepareKeyTimes];
    strokeColorAnimation.calculationMode = kCAAnimationDiscrete;
    strokeColorAnimation.duration = self.colorArray.count * 1.5;
    strokeColorAnimation.repeatCount = INFINITY;
    self.strokeColorAnimation = strokeColorAnimation;
}

- (NSArray*)prepareKeyTimes {
    NSMutableArray *keyTimesArray = [[NSMutableArray alloc] init];
    for(NSUInteger i=0; i<self.colorArray.count+1; i++){
        [keyTimesArray addObject:[NSNumber numberWithFloat:i*1.0/self.colorArray.count]];
    }
    return keyTimesArray;
}

- (void)startAnimation {
    if (self.isAnimating) {
        return;
    }
    self.isAnimating = YES;
    [self.circleLayer addAnimation:self.strokeLineAnimation forKey:@"strokeLineAnimation"];
    [self.circleLayer addAnimation:self.rotationAnimation forKey:@"rotationAnimation"];
    [self.circleLayer addAnimation:self.strokeColorAnimation forKey:@"strokeColorAnimation"];
}

- (void)stopAnimation {
    
    self.isAnimating = NO;
    [self.circleLayer removeAllAnimations];
}

@end


@interface MBTriangleLoadingView ()

@property (nonatomic, strong) CALayer *triangleLayer;

@end


@implementation MBTriangleLoadingView

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (instancetype)init {
    
    if(self = [super init]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.backgroundColor = [UIColor whiteColor];
    self.triangleLayer = [CALayer layer];
    self.triangleLayer.frame = CGRectMake(self.frame.size.width/2 - 25, self.frame.size.height/2 - 25, 50, 50);
    [self.layer addSublayer:self.triangleLayer];
}

- (void)updateAnimations {
    
    CGSize size = CGSizeMake(40, 40);
    CALayer *layer = self.triangleLayer;
    
    NSTimeInterval beginTime = CACurrentMediaTime();
    
    CGFloat circleSize = size.width / 4.0f;;
    CGFloat oX = (layer.bounds.size.width - size.width) / 2.0f;
    CGFloat oY = (layer.bounds.size.height - size.width) / 2.0f;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, circleSize, circleSize)];
    CGPoint pointA = CGPointMake(oX + size.width / 2.0f, oY + circleSize / 2.0f);
    CGPoint pointB = CGPointMake(oX + circleSize / 2.0f, oY + circleSize / 2.0f + sqrtf(powf((size.width - circleSize), 2) - powf((size.width / 2.0f - circleSize / 2.0f), 2)));
    CGPoint pointC = CGPointMake(oX + size.width - circleSize / 2.0f, pointB.y);
    
    for (int i = 0; i < 3; i++) {
        CAShapeLayer *circle = [CAShapeLayer layer];
        circle.path = path.CGPath;
        if (i == 0) {
            circle.fillColor = [UIColor colorWithRed:102.f/255 green:201.f/255 blue:255.f/255 alpha:1.0].CGColor;
        }
        if (i == 1) {
            circle.fillColor = [UIColor colorWithRed:252.f/255 green:79.f/255 blue:74.f/255 alpha:1.0].CGColor;
        }
        if (i == 2) {
            circle.fillColor = [UIColor colorWithRed:254.f/255 green:212.f/255 blue:31.f/255 alpha:1.0].CGColor;
        }
        circle.bounds = CGRectMake(0, 0, circleSize, circleSize);
        circle.position = pointA;
        circle.anchorPoint = CGPointMake(0.5f, 0.5f);
        circle.transform = CATransform3DMakeScale(0.0f, 0.0f, 0.0f);
        circle.shouldRasterize = YES;
        circle.rasterizationScale = [[UIScreen mainScreen] scale];
        
        CAKeyframeAnimation *transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.repeatCount = HUGE_VALF;
        transformAnimation.duration = 2.0f;
        transformAnimation.beginTime = beginTime - (i * transformAnimation.duration / 3.0f);;
        transformAnimation.keyTimes = @[@(0.0f), @(1.0f / 3.0f), @(2.0f / 3.0f), @(1.0)];
        
        transformAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        CATransform3D t1 = CATransform3DMakeTranslation(pointB.x - pointA.x, pointB.y - pointA.y, 0.0f);
        
        CATransform3D t2 = CATransform3DMakeTranslation(pointC.x - pointA.x, pointC.y - pointA.y, 0.0f);
        
        CATransform3D t3 = CATransform3DMakeTranslation(0.0f, 0.0f, 0.0f);
        
        transformAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],
                                      [NSValue valueWithCATransform3D:t1],
                                      [NSValue valueWithCATransform3D:t2],
                                      [NSValue valueWithCATransform3D:t3]];
        
        [circle addAnimation:transformAnimation forKey:@"animation"];
        [layer addSublayer:circle];
    }
}


- (void)startAnimation {
    
    if (self.isAnimating) {
        return;
    }
    self.isAnimating = YES;
    [self updateAnimations];
}

- (void)stopAnimation {
    
    self.isAnimating = NO;
    [self.triangleLayer removeAllAnimations];
}

@end


@interface MBSwapLoadingView () <CAAnimationDelegate>

@property (nonatomic, strong) CALayer *redLayer;
@property (nonatomic, strong) CALayer *yellowLayer;
@property (nonatomic, strong) CALayer *blueLayer;
@property (nonatomic, strong) CALayer *containerLayer;

@property (nonatomic, strong) UIColor *redColor;
@property (nonatomic, strong) UIColor *yellowColor;
@property (nonatomic, strong) UIColor *blueColor;


@end

@implementation MBSwapLoadingView

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (instancetype)init {
    
    if(self = [super init]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.blueColor = [UIColor colorWithRed:102.f/255 green:201.f/255 blue:255.f/255 alpha:1.0];
    self.redColor = [UIColor colorWithRed:252.f/255 green:79.f/255 blue:74.f/255 alpha:1.0];
    self.yellowColor = [UIColor colorWithRed:254.f/255 green:212.f/255 blue:31.f/255 alpha:1.0];
    CGFloat cx = self.frame.size.width/2 - 60;
    CGFloat cy = self.frame.size.height/2 - 30;
    CGFloat cw = 120;
    CGFloat ch = 60;
    self.containerLayer = [CALayer layer];
    self.containerLayer.frame = CGRectMake(cx, cy, cw, ch);
    [self.layer addSublayer:self.containerLayer];
    
    CGFloat bx = cw/2 - 18 - margin;
    CGFloat by = ch/2 - 6;
    CGFloat bw = 12;
    CGFloat bh = 12;
    self.blueLayer = [CALayer layer];
    self.blueLayer.frame = CGRectMake(bx, by, bw, bh);
    self.blueLayer.cornerRadius = 6;
    self.blueLayer.backgroundColor = self.blueColor.CGColor;
    [self.containerLayer addSublayer:self.blueLayer];
    
    CGFloat rx = cw/2 - 6;
    CGFloat ry = ch/2 - 6;
    CGFloat rw = 12;
    CGFloat rh = 12;
    self.redLayer = [CALayer layer];
    self.redLayer.frame = CGRectMake(rx, ry, rw, rh);
    self.redLayer.cornerRadius = 6;
    self.redLayer.backgroundColor = self.redColor.CGColor;
    [self.containerLayer addSublayer:self.redLayer];
    
    CGFloat yx = cw/2 + 6 + margin;
    CGFloat yy = ch/2 - 6;
    CGFloat yw = 12;
    CGFloat yh = 12;
    self.yellowLayer = [CALayer layer];
    self.yellowLayer.frame = CGRectMake(yx, yy, yw, yh);
    self.yellowLayer.cornerRadius = 6;
    self.yellowLayer.backgroundColor = self.yellowColor.CGColor;
    [self.containerLayer addSublayer:self.yellowLayer];
    
}

- (void)startAnimation {
    if (self.isAnimating) {
        return;
    }
    self.isAnimating = YES;
    CGFloat radius = (self.redLayer.position.x - self.blueLayer.position.x)/2;
    CGPoint otherRoundCenter1 = CGPointMake(self.blueLayer.frame.origin.x + radius + 6, self.redLayer.position.y);
    CGPoint otherRoundCenter2 = CGPointMake(self.redLayer.frame.origin.x + radius + 6, self.redLayer.position.y);
    //圆1的路径
    UIBezierPath *path1 = [[UIBezierPath alloc] init];
    [path1 addArcWithCenter:otherRoundCenter1 radius:radius startAngle:-M_PI endAngle:0 clockwise:true];
    UIBezierPath *path1_1 = [[UIBezierPath alloc] init];
    [path1_1 addArcWithCenter:otherRoundCenter2 radius:radius startAngle:-M_PI endAngle:0 clockwise:false];
    [path1 appendPath:path1_1];
    
    [self viewMovePathAnimWith:self.blueLayer path:path1 andTime:1.5];
    [self viewColorAnimWith:self.blueLayer fromColor:self.blueColor toColor:self.yellowColor andTime:1.5];
    
    UIBezierPath *path2 = [[UIBezierPath alloc] init];
    [path2 addArcWithCenter:otherRoundCenter1 radius:radius startAngle:0 endAngle:-M_PI clockwise:true];
    [self viewMovePathAnimWith:self.redLayer path:path2 andTime:1.5];
    [self viewColorAnimWith:self.redLayer fromColor:self.redColor toColor:self.blueColor andTime:1.5];
    
    UIBezierPath *path3 = [[UIBezierPath alloc] init];
    [path3 addArcWithCenter:otherRoundCenter2 radius:radius startAngle:0 endAngle:-M_PI clockwise:false];
    [self viewMovePathAnimWith:self.yellowLayer path:path3 andTime:1.5];
    [self viewColorAnimWith:self.yellowLayer fromColor:self.yellowColor toColor:self.blueColor andTime:1.5];
}

- (void)stopAnimation {
    self.isAnimating = NO;
    [self.blueLayer removeAllAnimations];
    [self.redLayer removeAllAnimations];
    [self.yellowLayer removeAllAnimations];
}

///设置view的移动路线，这样抽出来因为每个圆的只有路径不一样
- (void)viewMovePathAnimWith:(CALayer *)layer path:(UIBezierPath *)path andTime:(CGFloat)time {
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    anim.path = [path CGPath];
    anim.removedOnCompletion = false;
    anim.fillMode = kCAFillModeForwards;
    anim.calculationMode = kCAAnimationCubic;
    anim.repeatCount = HUGE_VALF;
    anim.duration = time;
    anim.autoreverses = NO;
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [layer addAnimation:anim forKey:@"position"];
    
}
///设置view的颜色动画
- (void)viewColorAnimWith:(CALayer *)layer fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor andTime:(CGFloat)time {
    
    CABasicAnimation *colorAnim = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    colorAnim.toValue = (__bridge id _Nullable)([toColor CGColor]);
    colorAnim.fromValue = (__bridge id _Nullable)([fromColor CGColor]);
    colorAnim.duration = time;
    colorAnim.autoreverses = NO;
    colorAnim.fillMode = kCAFillModeForwards;
    colorAnim.removedOnCompletion = NO;
    colorAnim.repeatCount = HUGE_VALF;
    [layer addAnimation:colorAnim forKey:@"backgroundColor"];
}

@end
