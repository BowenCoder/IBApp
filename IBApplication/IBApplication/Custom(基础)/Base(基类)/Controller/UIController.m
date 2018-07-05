//
//  UIController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/4.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIController.h"
#import "UIView+Ext.h"

@interface UIController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation UIController

#pragma mark - 重写方法

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVC];

}

- (void)didReceiveMemoryWarning {
    [self clearMemory];
    [super didReceiveMemoryWarning];
}

#pragma mark - 公开方法

- (void)initVC {
    [self initUI];
    [self initData];
}

- (void)initData {
    
}

- (void)initUI {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self forbidAutoLayout];
    [self setupBackBarItem];
}

- (void)setBackgroundImage:(UIImage *)image {
    [self.view setBackgroundImage:image pattern:NO];
}

- (void)clearMemory {
    
}

#pragma mark - 私有方法

/** 自定义返回按钮，本文下面有三种设计方法 */
- (void)setupBackBarItem {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    //设置颜色不然会变成蓝色
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    //主要是以下两个图片设置
    self.navigationController.navigationBar.backIndicatorImage = [UIImage imageNamed:@"back"];
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"back"];
    self.navigationItem.backBarButtonItem = backItem;
}

/**
 不允许自动调整布局，
 如果设置为NO，导航栏透明，导航栏遮住64像素，标签栏遮住44像素
 如果设置为NO，导航栏不透明，视图下移64像素，标签栏遮住44像素，也就是108像素
 如果设置为YES，导航栏不透明，视图下移64像素
 如果设置为YES，导航栏透明，我们设置屏幕为尺寸，视图自动下移64，高度减去108
 如果再加上标签栏，情况更复杂；所以都设置不透明，禁止自动布局
 */
- (void)forbidAutoLayout {
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

#pragma mark - 代理事件

#pragma mark - 合成存取



#pragma mark - 状态栏设置

// 返回NO表示要显示，返回YES将hiden
- (BOOL)prefersStatusBarHidden {
    return NO;
}

// 在plist中设置View controller -based status bar appearance值设为YES..
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
// 动画显示状态栏
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}


#pragma mark - 是否支持屏幕旋转
// 是否支持屏幕旋转
- (BOOL)shouldAutorotate {
    return NO;
}

// 支持的旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end


/*
 
 设置返回按钮三种方法
1、设置backBarButtonItem，在父视图设置才会有效
2、设置UIBarButtonItem的appearance，在本视图设置
UIImage *backButtonImage = [[UIImage imageNamed:@"back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 40, 0, 0) resizingMode:UIImageResizingModeTile];
[[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//参考自定义文字部分
[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
3、设置leftBarButtonItem
// 判断是否有上级页面，有的话再调用
if ([self.navigationController.viewControllers indexOfObject:self] > 0) {
    [self setupLeftBarButton];
}
- (void)setupLeftBarButton {
    // 自定义 leftBarButtonItem ，UIImageRenderingModeAlwaysOriginal 防止图片被渲染
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClick)];
    // 防止返回手势失效
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}
- (void)leftBarButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}
 
*/
 
 

