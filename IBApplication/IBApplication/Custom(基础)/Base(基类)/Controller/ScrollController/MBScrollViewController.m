//
//  IBScrollController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/5.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBScrollViewController.h"
#import "IBMacros.h"
#import "UIMacros.h"

@interface MBScrollViewController ()

@end

@implementation MBScrollViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateContentViewContentSize];
}

#pragma mark - 重写方法

- (void)onInit {
    [super onInit];
    [self setupContentView];
}

- (void)setupContentView {
    
    CGFloat height = kScreenHeight;
    if (self.navigationController) {
        height = height - kTopBarHeight;
    }
    if (self.tabBarController) {
        height = height - kBottomBarHeight;
    }
    self.contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, height)];
    self.contentView.backgroundColor = [UIColor lightGrayColor];
    self.contentView.showsVerticalScrollIndicator = NO;
    self.contentView.showsHorizontalScrollIndicator = NO;
    self.contentView.contentSize = kScreenBounds.size;
    if (@available(iOS 11.0, *)) {
        self.contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:self.contentView];
}

- (void)updateContentViewContentSize {
    
    CGFloat maxViewY = 0;
    CGFloat maxViewX = 0;
    NSArray *subViews = self.contentView.subviews;
    
    // 遍历视图中的所有控件，求出最大的Y值和最大的X值
    for (UIView *view in subViews) {
        if (CGRectGetMaxY(view.frame) > maxViewY) {
            maxViewY = CGRectGetMaxY(view.frame);
        }
        if (CGRectGetMaxX(view.frame) > maxViewX) {
            maxViewX = CGRectGetMaxX(view.frame);
        }
    }
    // 三目运算方法求出最大的宽和最大的高
    CGFloat contentH = maxViewY > kScreenBounds.size.height ? maxViewY : kScreenBounds.size.height;
    CGFloat contentW = maxViewX > kScreenBounds.size.width? maxViewX : kScreenBounds.size.width;
    
    self.contentView.contentSize = CGSizeMake(contentW, contentH);
}

@end
