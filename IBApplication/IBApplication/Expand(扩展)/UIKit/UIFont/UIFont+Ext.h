//
//  UIFont+Ext.h
//  IBApplication
//
//  Created by Bowen on 2018/9/17.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Ext)

/**
 * 兼容iOS8及其没有相关字体的情况，获取不到对应字体直接取系统默认字体
 **/
+ (UIFont *)mb_fontWithName:(NSString *)fontName size:(CGFloat)fontSize;

@end
