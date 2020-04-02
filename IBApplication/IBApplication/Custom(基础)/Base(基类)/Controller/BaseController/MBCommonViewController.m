//
//  MBCommonViewController.m
//  IBApplication
//
//  Created by Bowen on 2020/4/2.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBCommonViewController.h"
#import "UIView+Ext.h"
#import "UIBarButtonItem+Ext.h"
#import "IBImage.h"
#import "MBLogger.h"

@interface MBCommonViewController ()

@end

@implementation MBCommonViewController

#pragma mark - 重写方法

- (void)dealloc {
    MBLogD(@"#dealloc#");
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self onInit];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self onInit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupData];
}

#pragma mark - 公开方法

- (void)onInit
{
    self.supportedOrientationMask = UIInterfaceOrientationMaskAll;
    
    self.isStatusBarHidden = NO;
    self.statusBarStyle = UIStatusBarStyleLightContent;
    
    self.isForbidSwipeLeftBack = NO;
    
    self.isHomeIndicatorAutoHidden = NO;
    
    self.hidesBottomBarWhenPushed = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    if (@available(iOS 11.0, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)setupUI
{
    [self setupBackBarItem];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)setupData
{
    
}

- (void)setBackgroundImage:(UIImage *)image
{
    [self.view mb_setBackgroundImage:image pattern:NO];
}

- (UIBarButtonItem *)rightBarItemWithTitle:(NSString *)title titleColor:(UIColor *)color imageName:(NSString *)name action:(SEL)action
{
    UIBarButtonItem *item = [UIBarButtonItem itemWithTitle:title backgroundImage:[UIImage imageNamed:name] normalColor:color highlightedColor:nil target:self action:action];
    NSMutableArray *items = [NSMutableArray array];
    [items addObjectsFromArray:self.navigationItem.rightBarButtonItems];
    [items addObject:item];
    self.navigationItem.rightBarButtonItems = items;
    return item;
}

- (UIBarButtonItem *)leftBarItemWithTitle:(NSString *)title titleColor:(UIColor *)color imageName:(NSString *)name action:(SEL)action
{
    UIBarButtonItem *item = [UIBarButtonItem itemWithTitle:title backgroundImage:[UIImage imageNamed:name] normalColor:color highlightedColor:nil target:self action:action];
    NSMutableArray *items = [NSMutableArray array];
    [items addObjectsFromArray:self.navigationItem.leftBarButtonItems];
    [items addObject:item];
    self.navigationItem.leftBarButtonItems = items;
    return item;
}

#pragma mark - 私有方法

/** 自定义返回按钮，本文下面有三种设计方法 */
- (void)setupBackBarItem
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    // 主要是以下两个图片设置
    self.navigationController.navigationBar.backIndicatorImage = [UIImage imageNamed:@"back"];
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"back"];
    self.navigationItem.backBarButtonItem = backItem;
}


#pragma mark - 触发事件

#pragma mark - 回调事件

#pragma mark - 合成存取

#pragma mark - 侧滑返回

- (BOOL)forbidSwipeLeftBack
{
    return self.isForbidSwipeLeftBack;
}

#pragma mark - HomeIndicator

- (BOOL)prefersHomeIndicatorAutoHidden
{
    return self.isHomeIndicatorAutoHidden;
}

#pragma mark - 状态栏设置

// 返回NO表示要显示，返回YES将hiden
- (BOOL)prefersStatusBarHidden
{
    return self.isStatusBarHidden;
}

// 在plist中设置View controller -based status bar appearance值设为YES..
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.statusBarStyle;
}

// 动画显示状态栏
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

#pragma mark - 屏幕旋转

// 是否支持屏幕旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

// 支持的旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.supportedOrientationMask;
}

@end


/*
 设置返回按钮三种方法
1、设置backBarButtonItem，在父视图设置才会有效
 
2、设置UIBarButtonItem的appearance，在本视图设置
UIImage *backButtonImage = [[UIImage imageNamed:@"back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 40, 0, 0) resizingMode:UIImageResizingModeTile];
[[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
// 参考自定义文字部分
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
