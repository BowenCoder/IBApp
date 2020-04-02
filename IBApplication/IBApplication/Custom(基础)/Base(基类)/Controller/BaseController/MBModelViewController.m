//
//  MBModelViewController.m
//  IBApplication
//
//  Created by Bowen on 2020/4/2.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBModelViewController.h"

@interface MBModelViewController ()

@end

@implementation MBModelViewController

#pragma mark - 生命周期

- (void)onInit
{
    [super onInit];
    
    // 动态字体notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryDidChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - 初始化

#pragma mark - 添加控件

#pragma mark - 公开方法

#pragma mark - 网络请求

#pragma mark - 通知事件

- (void)contentSizeCategoryDidChanged:(NSNotification *)notification
{
    // 子类重写
}

#pragma mark - 对象事件

#pragma mark - 代理事件

#pragma mark - 其他方法

#pragma mark - 合成存取

@end
