//
//  IBController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/4.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBController.h"
#import "UIView+Ext.h"
#import "UIBarButtonItem+Ext.h"
#import "IBPicture.h"

@interface IBController ()

@property (nonatomic, strong) UIScrollView *scrollView;
///记录当前响应的textField
@property (nonatomic, strong) UIView *textView;

@end

@implementation IBController

#pragma mark - 重写方法

- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidBeginEditingNotification
                                                  object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self onInit];
}

- (void)didReceiveMemoryWarning {
    [self clearCache];
    [super didReceiveMemoryWarning];
}

#pragma mark - 公开方法

- (void)onInit {
    [self initUI];
    [self initData];
}

- (void)initUI {
    [self forbidAutoLayout];
    [self setupBackBarItem];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)initData {
    
}

- (void)clearCache {
    
}

- (void)setBackgroundImage:(UIImage *)image {
    [self.view setBackgroundImage:image pattern:NO];
}

- (void)enterLoginVC {
    
}

- (UIBarButtonItem *)rightBarItemWithTitle:(NSString *)title titleColor:(UIColor *)color imageName:(NSString *)name {
    UIBarButtonItem *item = [UIBarButtonItem itemWithTitle:title backgroundImage:[UIImage imageNamed:name] normalColor:color highlightedColor:nil target:self action:@selector(rightBarItemClick:)];
    NSMutableArray *items = [NSMutableArray array];
    [items addObjectsFromArray:self.navigationItem.rightBarButtonItems];
    [items addObject:item];
    self.navigationItem.rightBarButtonItems = items;
    return item;
}

- (UIBarButtonItem *)leftBarItemWithTitle:(NSString *)title titleColor:(UIColor *)color imageName:(NSString *)name {
    UIBarButtonItem *item = [UIBarButtonItem itemWithTitle:title backgroundImage:[UIImage imageNamed:name] normalColor:color highlightedColor:nil target:self action:@selector(rightBarItemClick:)];
    NSMutableArray *items = [NSMutableArray array];
    [items addObjectsFromArray:self.navigationItem.leftBarButtonItems];
    [items addObject:item];
    self.navigationItem.leftBarButtonItems = items;
    return item;
}

- (void)rightBarItemClick:(UIButton *)button {
    
}

- (void)leftBarItemClick:(UIButton *)button {
    
}

#pragma mark - 私有方法

/** 自定义返回按钮，本文下面有三种设计方法 */
- (void)setupBackBarItem {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
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
 如果再加上标签栏，情况更复杂；禁止自动布局，尽量保持透明
 */
- (void)forbidAutoLayout {
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = NO;
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (UIView *)superview:(UIView *)view classType:(Class)classType {
    
    UIView *superview = view.superview;
    while (superview) {
        if ([superview isKindOfClass:classType]) {
            if ([superview isKindOfClass:[UIScrollView class]]) {
                NSString *classNameString = NSStringFromClass([superview class]);
                if ([superview.superview isKindOfClass:[UITableView class]] == NO &&
                    [superview.superview isKindOfClass:[UITableViewCell class]] == NO &&
                    [classNameString hasPrefix:@"_"] == NO) {
                    return superview;
                }
            } else {
                return superview;
            }
        }
        superview = superview.superview;
    }
    return nil;
}

#pragma mark - 触发事件

/**
 键盘通知关联方法
 
 通知连续执行两个解决办法
 设置
 spellCheckingType = UITextSpellCheckingTypeNo;
 autocorrectionType = UITextAutocorrectionTypeNo;
 */
- (void)ib_keyboardWillShow:(NSNotification *)noti {
    
    //1.获取键盘显示完毕后的Y值
    CGRect rectEnd = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = rectEnd.origin.y;
    CGRect rect = [self.textView.superview convertRect:self.textView.frame toView:self.view.superview];
    UIScrollView *superView = (UIScrollView*)[self superview:self.textView classType:[UIScrollView class]];
    CGFloat textViewY =  CGRectGetMaxY(rect);
    //用键盘的Y值减去屏幕的高度计算平移的值
    CGFloat transformValue = keyboardY - textViewY - 5;
    if (superView) {
        CGFloat shouldOffsetY = superView.contentOffset.y - MIN(superView.contentOffset.y, transformValue);
        [UIView animateWithDuration:0.25 animations:^{
            [superView setContentOffset:CGPointMake(superView.contentOffset.x, shouldOffsetY)];
        }];
    } else {
        if (keyboardY < textViewY) {
            [UIView animateWithDuration:0.25 animations:^{
                self.view.transform = CGAffineTransformMakeTranslation(0, transformValue);
            }];
        }
    }
}

- (void)ib_keyboardWillHide:(NSNotification *)noti {
    
    UIScrollView *superView = (UIScrollView*)[self superview:self.textView classType:[UIScrollView class]];
    if (superView) {
        CGFloat contentHeight = MAX(superView.contentSize.height, CGRectGetHeight(superView.frame));
        CGFloat shouldOffsetY = contentHeight - CGRectGetHeight(superView.frame);
        if (shouldOffsetY < superView.contentOffset.y) {
            superView.contentOffset = CGPointMake(superView.contentOffset.x, shouldOffsetY);
        }
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)ib_textViewDidBeginEditing:(NSNotification*)notification {
    self.textView = notification.object;
}


#pragma mark - 回调事件


#pragma mark - 合成存取

- (void)setOpenKeyListener:(BOOL)openKeyListener {
    _openKeyListener = openKeyListener;
    if (_openKeyListener) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ib_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ib_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ib_textViewDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    }
}

- (IBNaviController *)naviController {
    if (self.navigationController && [self.navigationController isKindOfClass:[IBNaviController class]]) {
        return (IBNaviController *)self.navigationController;
    }
    return nil;
}

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
    return UIStatusBarAnimationFade;
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
 
 

