//
//  MBGradientView.m
//  IBApplication
//
//  Created by Bowen on 2019/8/10.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBGradientView.h"
#import "IBMacros.h"

@implementation MBGradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _startColor = k16RGBA(0x000000,1);
        _endColor = k16RGBA(0x000000,0);
        [self refreshLayer];
    }
    return self;
}

- (instancetype)initWithStyle:(MBGradientStyle)style {
    if (self = [super init]) {
        _style = style;
        _startColor = k16RGBA(0x000000,1);
        _endColor = k16RGBA(0x000000,0);
        [self refreshLayer];
    }
    return self;
}

- (void)refreshLayer {
    
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    
    if (_middleColor) {
        gradientLayer.colors = @[(__bridge id)self.startColor.CGColor,
                                 (__bridge id)self.middleColor.CGColor,
                                 (__bridge id)self.endColor.CGColor
                                 ];
        gradientLayer.locations = @[@0.0, @0.5, @1.0];
    } else {
        gradientLayer.colors = @[(__bridge id)self.startColor.CGColor,
                                 (__bridge id)self.endColor.CGColor
                                 ];
        gradientLayer.locations = @[@0.0, @1.0];
    }
    
    if (self.style == MBGradientTopToBottom) {
        gradientLayer.startPoint = CGPointMake(0.5, 0);
        gradientLayer.endPoint = CGPointMake(0.5, 1);
    } else if (self.style == MBGradientLeftToRight) {
        gradientLayer.startPoint = CGPointMake(0, 0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);
    } else if (self.style == MBGradientLeftTopToRightBottom) {
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
    } else if (self.style == MBGradientLeftBottomToRightTop) {
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(1, 0);
    }
}

- (void)setStartColor:(UIColor *)startColor {
    if(!startColor){
        startColor = k16RGBA(0x000000,1);
    }
    _startColor = startColor;
}

- (void)setMiddleColor:(UIColor *)middleColor {
    _middleColor = middleColor;
}

- (void)setEndColor:(UIColor *)endColor {
    if (!endColor) {
        endColor = k16RGBA(0x000000,0);
    }
    _endColor = endColor;
    [self refreshLayer];
}

@end
