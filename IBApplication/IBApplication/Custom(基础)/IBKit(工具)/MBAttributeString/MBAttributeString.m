//
//  MBAttributeString.m
//  IBApplication
//
//  Created by Bowen on 2020/3/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBAttributeString.h"

@implementation MBAttributeString

+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image
{
    return [MBAttributeString attributedStringWithImage:image baselineOffset:0 leftMargin:0 rightMargin:0];
}

+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)offset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin
{
    if (!image) {
        return nil;
    }
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    NSMutableAttributedString *string = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    [string addAttribute:NSBaselineOffsetAttributeName value:@(offset) range:NSMakeRange(0, string.length)];
    if (leftMargin > 0) {
        [string insertAttributedString:[self attributedStringWithFixedSpace:leftMargin] atIndex:0];
    }
    if (rightMargin > 0) {
        [string appendAttributedString:[self attributedStringWithFixedSpace:rightMargin]];
    }
    return string;
}

+ (NSAttributedString *)attributedStringWithFixedSpace:(CGFloat)width {
    UIGraphicsBeginImageContext(CGSizeMake(width, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [self attributedStringWithImage:image];
}



@end
