//
//  IBColor.m
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBColor.h"

@implementation IBColor

+ (UIColor *)randomColor {
    
    CGFloat r = arc4random_uniform(256) / 255.0;
    CGFloat g = arc4random_uniform(256) / 255.0;
    CGFloat b = arc4random_uniform(256) / 255.0;
    
    return [[UIColor alloc] initWithRed:r green:g blue:b alpha:1];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    
    CGFloat alpha, red, blue, green;
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = colorComponentFrom(colorString, 0, 1);
            green = colorComponentFrom(colorString, 1, 1);
            blue  = colorComponentFrom(colorString, 2, 1);
            break;
            
        case 4: // #ARGB
            alpha = colorComponentFrom(colorString, 0, 1);
            red   = colorComponentFrom(colorString, 1, 1);
            green = colorComponentFrom(colorString, 2, 1);
            blue  = colorComponentFrom(colorString, 3, 1);
            break;
            
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = colorComponentFrom(colorString, 0, 2);
            green = colorComponentFrom(colorString, 2, 2);
            blue  = colorComponentFrom(colorString, 4, 2);
            break;
            
        case 8: // #AARRGGBB
            alpha = colorComponentFrom(colorString, 0, 2);
            red   = colorComponentFrom(colorString, 2, 2);
            green = colorComponentFrom(colorString, 4, 2);
            blue  = colorComponentFrom(colorString, 6, 2);
            break;
            
        default:
            return nil;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

CGFloat colorComponentFrom(NSString *string, NSUInteger start, NSUInteger length) {
    
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

//还可以使用CGContextDrawLinearGradient实现
+ (UIColor *)linearGradient:(UIColor *)startColor endColor:(UIColor *)endColor direction:(IBGradientColorDirection)direction size:(CGSize)size {
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)startColor.CGColor,
                             (__bridge id)endColor.CGColor];
    gradientLayer.locations = @[@(0.0f), @(1.0f)];
    
    if (direction == IBGradientColorHorizontal) {
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 0);
    }else if (direction == IBGradientColorVertical){
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
    }else if (direction == IBGradientColorUpwardDiagonal){
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
    }else if (direction == IBGradientColorDownDiagonal){
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(1, 0);
    }
    
    gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, NO, 0);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIColor colorWithPatternImage:gradientImage];
}

+ (UIColor *)radialGradient:(UIColor *)centerColor outColor:(UIColor *)outColor size:(CGSize)size {
    
    UIGraphicsBeginImageContext(size);
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat raduis = MAX(size.width / 2, size.height / 2);
    CGPathAddArc(path, NULL, size.width / 2, size.height / 2, raduis, 0, 2 * M_PI, NO);
    
    [self _radialGradient:gc path:path startColor:centerColor.CGColor endColor:outColor.CGColor];
    CGPathRelease(path);
    
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIColor colorWithPatternImage:gradientImage];
}

+ (BOOL)equalToColor:(UIColor *)color anotherColor:(UIColor *)anotherColor {
    if (CGColorEqualToColor(color.CGColor, anotherColor.CGColor)) {
        return YES;
    }
    return NO;
}

+ (UIColor *)transitionColor:(UIColor *)startColor endColor:(UIColor *)endColor progress:(CGFloat)progress
{
    CGFloat startRed = 0.0, startGreen = 0.0, startBlue = 0.0, startAlpha = 0.0;
    CGFloat endRed = 0.0, endGreen = 0.0, endBlue = 0.0, endAlpha = 0.0;
    [startColor getRed:&startRed green:&startGreen blue:&startBlue alpha:&startAlpha];
    [endColor getRed:&endRed green:&endGreen blue:&endBlue alpha:&endAlpha];
    
    CGFloat red = startRed + progress * (endRed - startRed);
    CGFloat green = startGreen + progress * (endGreen - startGreen);
    CGFloat blue = startBlue + progress * (endBlue - startBlue);
    CGFloat alpha = startAlpha + progress * (endAlpha - startAlpha);
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (void)_radialGradient:(CGContextRef)context path:(CGPathRef)path startColor:(CGColorRef)startColor endColor:(CGColorRef)endColor {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0, 1.0};
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    CGPoint center = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMidY(pathRect));
    CGFloat radius = MAX(pathRect.size.width / 2.0, pathRect.size.height / 2.0) * sqrt(2);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextEOClip(context);
    
    CGContextDrawRadialGradient(context, gradient, center, 0, center, radius, 0);
    
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}


@end
