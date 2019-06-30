//
//  UIFont+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/9/17.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIFont+Ext.h"

@implementation UIFont (Ext)

+ (UIFont *)mb_fontWithName:(NSString *)fontName size:(CGFloat)fontSize {
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    if(!font) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    return font;
}

@end
