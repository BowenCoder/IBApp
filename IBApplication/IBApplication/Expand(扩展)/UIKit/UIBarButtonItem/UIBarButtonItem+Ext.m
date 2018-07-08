//
//  UIBarButtonItem+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIBarButtonItem+Ext.h"

// 文字默认颜色
#define UIButtonItemNormalColor          [UIColor whiteColor]
// 文字高亮颜色
#define UIButtonItemHighlightedColor     [UIColor clearColor]

@implementation UIBarButtonItem (Ext)

// 设置图片按钮,normal:常规图片，highlighted:高亮图片
- (id)initWithNormalIcon:(NSString *)normal highlightedIcon:(NSString *)highlighted target:(id)target action:(SEL)action {
    UIImage *image = [UIImage imageNamed:normal];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    if (highlighted) {
        [btn setBackgroundImage:[UIImage imageNamed:highlighted] forState:UIControlStateHighlighted];
    }
    btn.bounds = (CGRect){CGPointZero, image.size};
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [self initWithCustomView:btn];
}

+ (id)itemWithNormalIcon:(NSString *)normal highlightedIcon:(NSString *)highlighted target:(id)target action:(SEL)action {
    return [[self alloc] initWithNormalIcon:normal highlightedIcon:highlighted target:target action:action];
}

// 设置文字按钮，默认文字颜色：高亮颜色：
- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    return [self initWithTitle:title normalColor:UIButtonItemNormalColor highlightedColor:UIButtonItemHighlightedColor target:target action:action];
}

+ (id)itemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    return [[self alloc] initWithTitle:title target:target action:action];
}

// 设置文字按钮, backgroundImage:背景图片，normal：常规颜色 Highlighted：高亮颜色
- (id)initWithTitle:(NSString *)title backgroundImage:(UIImage *)backImage target:(id)target action:(SEL)action {
    return [self initWithTitle:title backgroundImage:backImage normalColor:UIButtonItemNormalColor highlightedColor:UIButtonItemHighlightedColor target:target action:action];
}

+ (id)itemWithTitle:(NSString *)title backgroundImage:(UIImage *)backImage target:(id)target action:(SEL)action {
    return [[self alloc] initWithTitle:title backgroundImage:backImage target:target action:action];
}

// 设置文字按钮，normal：常规颜色 Highlighted：高亮颜色
+ (id)itemWithTitle:(NSString *)title normalColor:(UIColor *)normal highlightedColor:(UIColor *)highlighted target:(id)target action:(SEL)action {
    return [[self alloc] initWithTitle:title backgroundImage:[UIImage new] normalColor:normal highlightedColor:highlighted target:target action:action];
}

- (id)initWithTitle:(NSString *)title normalColor:(UIColor *)normal highlightedColor:(UIColor *)highlighted target:(id)target action:(SEL)action {
    return [self initWithTitle:title backgroundImage:[UIImage new] normalColor:[UIColor whiteColor] highlightedColor:[UIColor whiteColor] target:target action:action];
}

// 设置文字按钮，backgroundImage:背景图片 normal：常规颜色 Highlighted：高亮颜色
+ (id)itemWithTitle:(NSString *)title backgroundImage:(UIImage *)backImage normalColor:(UIColor *)normal highlightedColor:(UIColor *)highlighted target:(id)target action:(SEL)action {
    return [[self alloc] initWithTitle:title backgroundImage:backImage normalColor:normal highlightedColor:highlighted target:target action:action];
}

- (id)initWithTitle:(NSString *)title backgroundImage:(UIImage *)backImage normalColor:(UIColor *)normal highlightedColor:(UIColor *)highlighted target:(id)target action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:normal forState:UIControlStateNormal];
    [btn setTitleColor:highlighted forState:UIControlStateHighlighted];
    [btn setBackgroundImage:backImage forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    if (CGSizeEqualToSize(backImage.size, CGSizeZero)) {
        CGSize size = [btn.titleLabel sizeThatFits:CGSizeMake(100, 44)];
        btn.frame = CGRectMake(0, 0, size.width, size.height);
    }else {
        btn.frame = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    }
    
    return [self initWithCustomView:btn];
}


@end
