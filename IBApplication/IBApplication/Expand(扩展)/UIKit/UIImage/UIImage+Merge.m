//
//  UIImage+Merge.m
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIImage+Merge.h"

@implementation UIImage (Merge)

/**
 *  @brief  合并两个图片
 *
 *  @param firstImage  一个图片
 *  @param secondImage 二个图片
 *
 *  @return 合并后图片
 */
+ (UIImage*)mergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    CGImageRef firstImageRef = firstImage.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    CGImageRef secondImageRef = secondImage.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    UIGraphicsBeginImageContext(mergedSize);
    [firstImage drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [secondImage drawInRect:CGRectMake(0, 0, secondWidth, secondHeight)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 *  加水印
 */
- (UIImage *)waterWithText:(NSString *)text direction:(ImageWaterDirect)direction fontColor:(UIColor *)fontColor fontPoint:(CGFloat)fontPoint marginXY:(CGPoint)marginXY {
    CGSize size = self.size;
    CGRect rect = (CGRect){CGPointZero, size};
    //新建图片图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    //绘制图片
    [self drawInRect:rect];
    //绘制文本
    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:fontPoint], NSForegroundColorAttributeName : fontColor};
    CGRect strRect = [self calWidth:text attr:attr direction:direction rect:rect marginXY:marginXY];
    [text drawInRect:strRect withAttributes:attr];
    //获取图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //结束图片图形上下文
    UIGraphicsEndImageContext();
    return newImage;
}

- (CGRect)calWidth:(NSString *)str attr:(NSDictionary *)attr direction:(ImageWaterDirect)direction rect:(CGRect)rect marginXY:(CGPoint)marginXY {
    
    CGSize size = [str sizeWithAttributes:attr];
    CGRect calRect = [self rectWithRect:rect size:size direction:direction marginXY:marginXY];
    return calRect;
}

- (CGRect)rectWithRect:(CGRect)rect size:(CGSize)size direction:(ImageWaterDirect)direction marginXY:(CGPoint)marginXY {
   
    CGPoint point = CGPointZero;
    //右上
    if (ImageWaterDirectTopRight == direction) point = CGPointMake(rect.size.width - size.width, 0);
    //左下
    if (ImageWaterDirectBottomLeft == direction) point = CGPointMake(0, rect.size.height - size.height);
    //右下
    if (ImageWaterDirectBottomRight == direction) point = CGPointMake(rect.size.width - size.width, rect.size.height - size.height);
    //正中
    if (ImageWaterDirectCenter == direction) point = CGPointMake((rect.size.width - size.width) * .5f, (rect.size.height - size.height) * .5f);
    point.x += marginXY.x;
    point.y += marginXY.y;
    CGRect calRect = (CGRect){point, size};
    return calRect;
}

/**
 *  加水印
 */
- (UIImage *)waterWithWaterImage:(UIImage *)waterImage direction:(ImageWaterDirect)direction waterSize:(CGSize)waterSize marginXY:(CGPoint)marginXY {
    
    CGSize size = self.size;
    CGRect rect = (CGRect){CGPointZero, size};
    //新建图片图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    //绘制图片
    [self drawInRect:rect];
    //计算水印的rect
    CGSize waterImageSize = CGSizeEqualToSize(waterSize, CGSizeZero) ? waterImage.size : waterSize;
    CGRect calRect = [self rectWithRect:rect size:waterImageSize direction:direction marginXY:marginXY];
    //绘制水印图片
    [waterImage drawInRect:calRect];
    //获取图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //结束图片图形上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
