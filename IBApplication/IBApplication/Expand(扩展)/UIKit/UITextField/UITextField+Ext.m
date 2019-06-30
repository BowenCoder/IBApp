//
//  UITextField+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UITextField+Ext.h"
#import "UIView+Ext.h"

@implementation UITextField (Ext)

- (void)mb_setCursorColor:(UIColor *)color {
    self.tintColor = color;
}

- (void)mb_setPlaceholder:(NSString *)placeholder
                    color:(UIColor *)color
                     font:(CGFloat)font {
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:placeholder];
    [attr addAttribute:NSForegroundColorAttributeName
                 value:color
                 range:NSMakeRange(0, placeholder.length)];
    [attr addAttribute:NSFontAttributeName
                 value:[UIFont systemFontOfSize:font]
                 range:NSMakeRange(0, placeholder.length)];
    self.attributedPlaceholder = attr;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
}

- (void)mb_leftLabelTitle:(NSString *)title
               titleColor:(UIColor *)titleColor
                titleFont:(CGFloat)font
                    width:(CGFloat)width
          backgroundColor:(UIColor *)backgroundColor {
    
    [self _buttonWithText:title
                   isLeft:YES
                textColor:titleColor
                 textFont:[UIFont systemFontOfSize:font]
                    width:width
                   target:nil
                 selector:nil
          backgroundColor:backgroundColor];
}

- (UIButton *)mb_rightButtonTitle:(NSString *)title
                       titleColor:(UIColor *)titleColor
                        titleFont:(CGFloat)font
                            width:(CGFloat)width
                           target:(id)target
                         selector:(SEL)selector
                  backgroundColor:(UIColor *)backgroundColor {
    
    return [self _buttonWithText:title
                          isLeft:NO
                       textColor:titleColor
                        textFont:[UIFont systemFontOfSize:font]
                           width:width
                          target:target
                        selector:selector
                 backgroundColor:backgroundColor];
}

- (UIButton *)_buttonWithText:(NSString *)text
                       isLeft:(BOOL)isLeft
                    textColor:(UIColor *)textColor
                     textFont:(UIFont *)font
                        width:(CGFloat)width
                       target:(id)target
                     selector:(SEL)selector
              backgroundColor:(UIColor *)backgroundColor {
    
    UIButton *btn = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, width, self.bounds.size.height)];
    btn.titleLabel.font = font;
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    if (isLeft) {
        [self setLeftViewMode:UITextFieldViewModeAlways];
        [self setLeftView:btn];
    } else {
        [self setRightViewMode:UITextFieldViewModeAlways];
        [self setRightView:btn];
        [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    
    [btn setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin];
    
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:textColor forState:UIControlStateNormal];
    [btn setBackgroundColor:backgroundColor];
    
    return btn;
}

/*
 
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

-(CGRect)placeholderRectForBounds:(CGRect)bounds {
    
    CGFloat originX = bounds.origin.x + self.leftView.right + 5;
    CGFloat originY = bounds.origin.y + 4;
    CGFloat width   = bounds.size.width - self.rightView.width - self.leftView.width - 5;
    CGFloat height  = bounds.size.height;
    CGRect inset = CGRectMake(originX, originY, width, height);//更好理解些
    
    return inset;
    
}

// 修改文本展示区域，一般跟editingRectForBounds一起重写
- (CGRect)textRectForBounds:(CGRect)bounds {
    
    CGFloat originX = bounds.origin.x + self.leftView.right + 5;
    CGFloat originY = bounds.origin.y;
    CGFloat width   = bounds.size.width - self.rightView.width - self.leftView.width - 5;
    CGFloat height  = bounds.size.height;
    CGRect inset = CGRectMake(originX, originY, width, height);//更好理解些
    
    return inset;
}

// 重写来编辑区域，可以改变光标起始位置，以及光标最右到什么地方，placeHolder的位置也会改变
- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    CGFloat originX = bounds.origin.x + self.leftView.right + 5;
    CGFloat originY = bounds.origin.y;
    CGFloat width   = bounds.size.width - self.rightView.width - self.leftView.width - 5;
    CGFloat height  = bounds.size.height;
    CGRect inset = CGRectMake(originX, originY, width, height);//更好理解些
    
    return inset;
    
}

#pragma clang diagnostic pop
 
*/

@end
