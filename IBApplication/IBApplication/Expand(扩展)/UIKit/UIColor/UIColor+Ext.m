//
//  UIColor+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIColor+Ext.h"

@implementation UIColor (Ext)

+ (UIColor *)randomColor {
    
    CGFloat r = arc4random_uniform(256) / 255.0;
    CGFloat g = arc4random_uniform(256) / 255.0;
    CGFloat b = arc4random_uniform(256) / 255.0;
    
    return [[UIColor alloc] initWithRed:r green:g blue:b alpha:1];
}

/**
 *  @brief  渐变颜色
 *
 *  @param c1     开始颜色
 *  @param c2     结束颜色
 *  @param height 渐变高度
 *
 *  @return 渐变颜色
 */
+ (UIColor*)gradientFromColor:(UIColor*)c1 toColor:(UIColor*)c2 withHeight:(int)height {
    
    CGSize size = CGSizeMake(1, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    NSArray* colors = [NSArray arrayWithObjects:(id)c1.CGColor, (id)c2.CGColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (__bridge CFArrayRef)colors, NULL);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    UIGraphicsEndImageContext();
    
    return [UIColor colorWithPatternImage:image];
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


@end
