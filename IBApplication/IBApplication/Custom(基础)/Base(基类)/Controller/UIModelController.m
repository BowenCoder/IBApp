//
//  UIModelController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIModelController.h"

@interface UIModelController ()

@end

@implementation UIModelController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 重写方法

#pragma mark - 公开方法

- (void)enterLoginVC {
    
}


#pragma mark - 私有方法

///键盘通知关联方法
- (void)keyboardWillChangeFrame:(NSNotification *)noteInfo {
    
//    NSLog(@"通知的内容：%@",noteInfo);
    //1.获取键盘显示完毕或者隐藏完毕后的Y值
    CGRect rectEnd = [noteInfo.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = rectEnd.origin.y;
    //用键盘的Y值减去屏幕的高度计算平移的值
    CGFloat transformValue = keyboardY - self.view.frame.size.height;
//    NSLog(@"%f",transformValue);
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.transform = CGAffineTransformMakeTranslation(0, transformValue);
    }];
}


#pragma mark - 代理事件


#pragma mark - 合成存取

- (void)setOpenKeyListener:(BOOL)openKeyListener {
    
    _openKeyListener = openKeyListener;
    if (_openKeyListener) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}


@end
