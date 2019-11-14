//
//  MBAlignmentLabel.m
//  IBApplication
//
//  Created by Bowen on 2019/8/12.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBAlignmentLabel.h"

@implementation MBAlignmentLabel

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    UIEdgeInsets insets = self.contentEdgeInsets;
        
    CGRect textRect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, insets) limitedToNumberOfLines:numberOfLines];
    
    // 设置内边距
    textRect.origin.x    -= insets.left;
    textRect.origin.y    -= insets.top;
    textRect.size.width  += (insets.left + insets.right);
    textRect.size.height += (insets.top + insets.bottom);
    
    // 设置对齐方式
    switch (self.textAlign) {
        case MBTextAlignmentLeftTop:
            textRect.origin.x = bounds.origin.x;
            textRect.origin.y = bounds.origin.y;
            break;
        case MBTextAlignmentLeftCenter:
            textRect.origin.x = bounds.origin.x;
            textRect.origin.y = (bounds.size.height - textRect.size.height)*0.5;
            break;
        case MBTextAlignmentLeftBottom:
            textRect.origin.x = bounds.origin.x;
            textRect.origin.y = bounds.size.height - textRect.size.height;
            break;
        case MBTextAlignmentRightTop:
            textRect.origin.x = bounds.size.width - textRect.size.width;
            textRect.origin.y = bounds.origin.y;
            break;
        case MBTextAlignmentRightCenter:
            textRect.origin.x = bounds.size.width - textRect.size.width;
            textRect.origin.y = (bounds.size.height - textRect.size.height)*0.5;
            break;
        case MBTextAlignmentRightBottom:
            textRect.origin.x = bounds.size.width - textRect.size.width;
            textRect.origin.y = bounds.size.height - textRect.size.height;
            break;
        case MBTextAlignmentCenterTop:
            textRect.origin.x = (bounds.size.width - textRect.size.width)*0.5;
            textRect.origin.y = bounds.origin.y;
            break;
        case MBTextAlignmentCenterBottom:
            textRect.origin.x = (bounds.size.width - textRect.size.width)*0.5;
            textRect.origin.y = bounds.size.height - textRect.size.height;
            break;
        case MBTextAlignmentCenter:
            textRect.origin.x = (bounds.size.width - textRect.size.width)*0.5;
            textRect.origin.y = (bounds.size.height - textRect.size.height)*0.5;
            break;
        default:
            break;
    }
    return textRect;
}

- (void)drawTextInRect:(CGRect)rect
{
    if (self.textAlign != MBTextAlignmentDefault) {
        rect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    }
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.contentEdgeInsets)];
}

@end
