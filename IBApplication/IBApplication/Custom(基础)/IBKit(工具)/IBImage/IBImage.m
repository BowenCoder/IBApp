//
//  IBImage.m
//  IBApplication
//
//  Created by BowenCoder on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBImage.h"
#import <Accelerate/Accelerate.h>
#import "IBMacros.h"

@implementation IBImage

+ (UIImage *)imageWithFileName:(NSString *)name {
    
    return [self imageWithName:name inBundle:nil];
}

+ (UIImage *)imageWithName:(NSString *)name inBundle:(NSString *)bundleName {
    
    NSString *extension = @"png";
    bundleName = [bundleName stringByAppendingString:@".bundle"];
    NSArray *components = [name componentsSeparatedByString:@"."];
    if ([components count] >= 2) {
        NSUInteger lastIndex = components.count - 1;
        extension = [components objectAtIndex:lastIndex];
        
        name = [name substringToIndex:(name.length-(extension.length+1))];
    }
    
    // 如果为Retina屏幕且存在对应图片，则返回Retina图片，否则查找普通图片
    if ([UIScreen mainScreen].scale == 2.0) {
        NSString *tempName = [name stringByAppendingString:@"@2x"];
        NSString *path = [IBImage pathWithName:tempName extension:extension inBundle:bundleName];
        if (path != nil) {
            return [UIImage imageWithContentsOfFile:path];
        }
    }
    
    if ([UIScreen mainScreen].scale == 3.0) {
        NSString *tempName = [name stringByAppendingString:@"@3x"];
        NSString *path = [IBImage pathWithName:tempName extension:extension inBundle:bundleName];
        if (path != nil) {
            return [UIImage imageWithContentsOfFile:path];
        }
    }
    
    NSString *path = [IBImage pathWithName:name extension:extension inBundle:bundleName];
    if (path) {
        return [UIImage imageWithContentsOfFile:path];
    }
    return nil;
}

+ (NSString *)pathWithName:(NSString *)name extension:(NSString *)extension inBundle:(NSString *)bundleName {
    
    if (kIsEmptyString(bundleName)) {
        return [[NSBundle mainBundle] pathForResource:name ofType:extension];
    } else {
        return [[NSBundle mainBundle] pathForResource:name ofType:extension inDirectory:bundleName];
    }
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    
    CGSize size = CGSizeMake(1.0f, 1.0f);
    return [self imageWithColor:color size:size];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    
    CGRect rect = CGRectMake(0.0f, 0.0f,size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)stretchImageNamed:(NSString *)name {
    
    return [self stretchImageWithImage:[UIImage imageNamed:name]];
}

+ (UIImage *)stretchImageWithImage:(UIImage *)image {
    
    CGFloat top = image.size.height/2.0;
    CGFloat left = image.size.width/2.0;
    CGFloat bottom = image.size.height/2.0;
    CGFloat right = image.size.width/2.0;
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
}

+ (UIImage *)resizedImage:(UIImage *)image size:(CGSize)newSize
{
    return [self resizedImage:image size:newSize radius:0];
}

+ (UIImage *)resizedImage:(UIImage*)image size:(CGSize)newSize radius:(CGFloat)radius {
    
    UIGraphicsBeginImageContext(newSize);
    if (radius > 0.0) {
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,0,newSize.width,newSize.height)
                                    cornerRadius:radius] addClip];
    }
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (BOOL)equalToImage:(UIImage *)image anotherImage:(UIImage *)anotherImage {
    NSData *orginalData = UIImagePNGRepresentation(image);
    NSData *anotherData = UIImagePNGRepresentation(anotherImage);
    if ([orginalData isEqual:anotherData]) {
        return YES;
    }
    return NO;
}

@end

@implementation IBImage (Special)

+ (UIImage *)flip:(UIImage *)image horizontal:(BOOL)horizontal {
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClipToRect(ctx, rect);
    if (horizontal) {
        CGContextRotateCTM(ctx, M_PI);
        CGContextTranslateCTM(ctx, -rect.size.width, -rect.size.height);
    }
    CGContextDrawImage(ctx, rect, image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)fixOrientation:(UIImage *)image {
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)captureCircleImage:(UIImage *)image borderWidth:(CGFloat)border borderColor:(UIColor *)color {
    
    CGFloat imageW = image.size.width + border * 2;
    CGFloat imageH = image.size.height + border * 2;
    imageW = MIN(imageH, imageW);
    imageH = imageW;
    CGSize imageSize = CGSizeMake(imageW, imageH);
    //新建一个图形上下文
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [color set];
    //画大圆
    CGFloat bigRadius = imageW * 0.5;
    CGFloat centerX = imageW * 0.5;
    CGFloat centerY = imageH * 0.5;
    CGContextAddArc(ctx,centerX , centerY, bigRadius, 0, M_PI * 2, 0);
    CGContextFillPath(ctx);
    //画小圆
    CGFloat smallRadius = bigRadius - border;
    CGContextAddArc(ctx , centerX , centerY , smallRadius ,0, M_PI * 2, 0);
    //切割
    CGContextClip(ctx);
    //画图片
    [image drawInRect:CGRectMake(border, border, imageW, imageH)];
    //从上下文中取出图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)blendImage:(UIImage *)image tintColor:(UIColor *)tintColor {
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    // 保留灰度信息
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    // 保留透明度信息
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (UIImage *)blurredImage:(UIImage *)image blurValue:(CGFloat)blurValue {
    
    if (blurValue < 0.0 || blurValue > 2.0) {
        blurValue = 0.5;
    }
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    int boxSize = blurValue * 40;
    boxSize = boxSize - (boxSize % 2) + 1;
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (!error)
    {
        error = vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}

+ (UIImage *)gradientImageWithSize:(CGSize)size gradientColors:(NSArray *)colors percentage:(NSArray *)percents gradientType:(IBImageGradientType)gradientType
{
    NSMutableArray *cgColors = [NSMutableArray array];
    for(UIColor *color in colors) {
        [cgColors addObject:(id)color.CGColor];
    }
    
    CGFloat locations[percents.count];
    for (int i = 0; i < percents.count; i++) {
        locations[i] = [percents[i] floatValue];
    }
    
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)cgColors, locations);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case IBImageGradientTopToBottom:
            start = CGPointMake(size.width/2, 0.0);
            end = CGPointMake(size.width/2, size.height);
            break;
        case IBImageGradientLeftToRight:
            start = CGPointMake(0.0, size.height/2);
            end = CGPointMake(size.width, size.height/2);
            break;
        case IBImageGradientLeftTopToRightBottom:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, size.height);
            break;
        case IBImageGradientLeftBottomToRightTop:
            start = CGPointMake(0.0, size.height);
            end = CGPointMake(size.width, 0.0);
            break;
        default:
            break;
    }
    CGGradientDrawingOptions options = kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation;
    CGContextDrawLinearGradient(context, gradient, start, end, options);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation IBImage (Merge)

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

+ (UIImage *)water:(UIImage *)image text:(NSString *)text direction:(ImageWaterDirect)direction fontColor:(UIColor *)fontColor fontPoint:(CGFloat)fontPoint marginXY:(CGPoint)marginXY {
    
    CGSize size = image.size;
    CGRect rect = (CGRect){CGPointZero, size};
    //新建图片图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    //绘制图片
    [image drawInRect:rect];
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

+ (UIImage *)water:(UIImage *)image waterImage:(UIImage *)waterImage direction:(ImageWaterDirect)direction waterSize:(CGSize)waterSize marginXY:(CGPoint)marginXY {
    
    CGSize size = image.size;
    CGRect rect = (CGRect){CGPointZero, size};
    //新建图片图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    //绘制图片
    [image drawInRect:rect];
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

+ (CGRect)calWidth:(NSString *)str attr:(NSDictionary *)attr direction:(ImageWaterDirect)direction rect:(CGRect)rect marginXY:(CGPoint)marginXY {
    
    CGSize size = [str sizeWithAttributes:attr];
    CGRect calRect = [self rectWithRect:rect size:size direction:direction marginXY:marginXY];
    return calRect;
}

+ (CGRect)rectWithRect:(CGRect)rect size:(CGSize)size direction:(ImageWaterDirect)direction marginXY:(CGPoint)marginXY {
    
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

@end
