//
//  IBActionItem.m
//  IBApplication
//
//  Created by Bowen on 2018/9/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBActionItem.h"

@implementation IBActionItem

+ (instancetype)itemWithType:(IBActionType)type image:(UIImage *)image title:(NSString *)title tintColor:(UIColor *)tintColor handler:(IBActionHandler)handler {
    
    IBActionItem *item = [[IBActionItem alloc] init];
    item.type  = type;
    item.image = image;
    item.title = title;
    item.tintColor = tintColor;
    item.handler = handler;
    
    return item;
}

@end

// float
CGFloat const IBActionDefaultMargin = 10;
CGFloat const IBActionContentMaxScale = 0.65;
CGFloat const IBActionRowHeight = 44;
CGFloat const IBActionTitleLineSpacing = 2.5;
CGFloat const IBActionTitleKernSpacing = 0.5;
CGFloat const IBActionItemTitleFontSize = 16;
CGFloat const IBActionItemContentSpacing = 5;
CGFloat const IBActionSectionHeight = 10;

// color
NSString * const IBActionTitleColor = @"#888888";
NSString * const IBActionBGColor = @"#E8E8ED";
NSString * const IBActionRowNormalColor = @"#FBFBFE";
NSString * const IBActionRowHighlightedColor = @"#F1F1F5";
NSString * const IBActionRowTopLineColor = @"#D7D7D8";
NSString * const IBActionItemNormalColor = @"#000000";
NSString * const IBActionItemHighlightedColor = @"#E64340";
