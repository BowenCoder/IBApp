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

- (void)goLogin {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 合成存取
- (void)setOpenKeyboard:(BOOL)openKeyboard {
    _openKeyboard = openKeyboard;
    //监听键盘的弹出事件
    //1.创建一个NSNotificationCenter对象
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (openKeyboard) {
        //2.监听键盘弹出发出的通知
        [center addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

//通知关联方法
- (void)keyboardWillChangeFrame:(NSNotification *)noteInfo {
    
//    NSLog(@"通知的内容：%@",noteInfo);
    //1.获取键盘显示完毕或者隐藏完毕后的Y值
    CGRect rectEnd = [noteInfo.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = rectEnd.origin.y;
    //用键盘的Y值减去屏幕的高度计算平移的值
    CGFloat transformValue = keyboardY - self.view.frame.size.height;
    NSLog(@"%f",transformValue);
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.transform = CGAffineTransformMakeTranslation(0, transformValue);
    }];
}


@end
