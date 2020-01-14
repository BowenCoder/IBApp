//
//  MBActionItem.m
//  IBApplication
//
//  Created by Bowen on 2018/9/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBActionItem.h"

@implementation MBActionItem

+ (instancetype)itemWithType:(MBActionType)type image:(UIImage *)image title:(NSString *)title tintColor:(UIColor *)tintColor handler:(MBActionHandler)handler {
    
    MBActionItem *item = [[MBActionItem alloc] init];
    item.type  = type;
    item.image = image;
    item.title = title;
    item.tintColor = tintColor;
    item.handler = handler;
    
    return item;
}

@end

// float
CGFloat const MBActionDefaultMargin = 10;
CGFloat const MBActionContentMaxScale = 0.65;
CGFloat const MBActionRowHeight = 44;
CGFloat const MBActionTitleLineSpacing = 2.5;
CGFloat const MBActionTitleKernSpacing = 0.5;
CGFloat const MBActionItemTitleFontSize = 16;
CGFloat const MBActionItemContentSpacing = 5;
CGFloat const MBActionSectionHeight = 10;

// color
NSString * const MBActionTitleColor = @"#888888";
NSString * const MBActionBGColor = @"#E8E8ED";
NSString * const MBActionRowNormalColor = @"#FBFBFE";
NSString * const MBActionRowHighlightedColor = @"#F1F1F5";
NSString * const MBActionRowTopLineColor = @"#D7D7D8";
NSString * const MBActionItemNormalColor = @"#000000";
NSString * const MBActionItemHighlightedColor = @"#E64340";
