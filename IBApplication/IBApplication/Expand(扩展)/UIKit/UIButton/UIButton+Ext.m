//
//  UIButton+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIButton+Ext.h"
#import <objc/runtime.h>
#import "IBImage.h"

static NSString *const kIndicatorViewKey = @"indicatorView";
static NSString *const kButtonTextObjectKey = @"buttonTextObject";

@implementation UIButton (Ext)

- (UIEdgeInsets)extraAreaInsets {
    return [objc_getAssociatedObject(self, @selector(extraAreaInsets)) UIEdgeInsetsValue];
}

- (void)setExtraAreaInsets:(UIEdgeInsets)touchAreaInsets {
    NSValue *value = [NSValue valueWithUIEdgeInsets:touchAreaInsets];
    objc_setAssociatedObject(self, @selector(extraAreaInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)hitScale {
    return [objc_getAssociatedObject(self, @selector(hitScale)) floatValue];
}

- (void)setHitScale:(CGFloat)hitScale {
    CGFloat width = self.bounds.size.width * hitScale;
    CGFloat height = self.bounds.size.height * hitScale;
    self.extraAreaInsets = UIEdgeInsetsMake(-height, -width,-height, -width);
    objc_setAssociatedObject(self, @selector(hitScale), @(hitScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    // 如果 button 边界值无变化  失效 隐藏 或者透明 直接返回
    if(UIEdgeInsetsEqualToEdgeInsets(self.extraAreaInsets, UIEdgeInsetsZero) ||
       !self.enabled || self.hidden || self.alpha == 0 ) {
        return [super pointInside:point withEvent:event];
    }
    
    UIEdgeInsets touchAreaInsets = self.extraAreaInsets;
    CGRect bounds = self.bounds;
    bounds = CGRectMake(bounds.origin.x - touchAreaInsets.left,
                        bounds.origin.y - touchAreaInsets.top,
                        bounds.size.width + touchAreaInsets.left + touchAreaInsets.right,
                        bounds.size.height + touchAreaInsets.top + touchAreaInsets.bottom);
    return CGRectContainsPoint(bounds, point);
}

/**
 *  @brief  使用颜色设置按钮背景
 *
 *  @param backgroundColor 背景颜色
 *  @param state           按钮状态
 */
- (void)mb_setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    
    [self setBackgroundImage:[IBImage imageWithColor:backgroundColor] forState:state];
}

- (void)mb_startTime:(NSInteger )timeout title:(NSString *)tittle waitTittle:(NSString *)waitTittle {
    
    __block NSInteger timeOut=timeout; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeOut<=0) { //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self setTitle:tittle forState:UIControlStateNormal];
                self.userInteractionEnabled = YES;
            });
        } else {
            int seconds = timeOut % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self setTitle:[NSString stringWithFormat:@"%@%@",strTime,waitTittle] forState:UIControlStateNormal];
                self.userInteractionEnabled = NO;
            });
            timeOut--;
        }
    });
    dispatch_resume(_timer);
    
}

@end

@implementation UIButton (Indicator)

- (void)mb_showIndicator {
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    [indicator startAnimating];
    
    NSString *currentButtonText = self.titleLabel.text;
    
    objc_setAssociatedObject(self, &kButtonTextObjectKey, currentButtonText, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &kIndicatorViewKey, indicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setTitle:@"" forState:UIControlStateNormal];
    self.enabled = NO;
    [self addSubview:indicator];
}

- (void)mb_hideIndicator {
    
    NSString *currentButtonText = (NSString *)objc_getAssociatedObject(self, &kButtonTextObjectKey);
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)objc_getAssociatedObject(self, &kIndicatorViewKey);
    
    [indicator removeFromSuperview];
    [self setTitle:currentButtonText forState:UIControlStateNormal];
    self.enabled = YES;
}

@end
