//
//  UIPopupManager.m
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIPopupManager.h"

#define kPopViewModalBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]

@interface UIPopupManager ()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIView *customView;
@property (nonatomic, assign) UIPopupAnimation animationType;
@property (nonatomic, assign) double animationDuration;

@end

@implementation UIPopupManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRoute:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [self initManager];
    }
    return self;
}

- (void)changeRoute:(NSNotification *)notification
{
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait) {
        //竖屏
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        _backgroundView.frame = window.bounds;
        // 更新子控件布局
    } else {
        if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight) {
            //横屏
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            _backgroundView.frame = window.bounds;
            // 更新子控件布局
        }
    }
}


- (void)initManager {
    
    // 初始化
    _supportAnimateAlpha = YES;
    _supportDismissForClickBackground = YES;
    _animationType = UIPopupAnimationNone;
    _animationDuration = 0;

     UIWindow *window = [UIApplication sharedApplication].keyWindow;
     _backgroundView = [[UIView alloc] initWithFrame:window.bounds];
     _backgroundView.backgroundColor = kPopViewModalBackgroundColor;
     [window addSubview:_backgroundView];
}

- (void)addCustomView:(UIView *)customView {
    
    _customView = customView;
    _animationType = UIPopupAnimationNone;
    _animationDuration = 0;
    [self didAddCustomView];
}

- (void)addCustomView:(UIView *)customView
                 type:(UIPopupAnimation)animationType
             duration:(double)duration {
    
    _customView = customView;
    _animationType = animationType;
    _animationDuration = duration;
    [self didAddCustomView];
}

- (void)didAddCustomView
{
    CGRect customFrame = _customView.frame;
    CGRect tempFrame;
    switch (_animationType) {
        case UIPopupAnimationNone:
            tempFrame = customFrame;
            break;
        case UIPopupAnimationTopLeft:
            tempFrame = CGRectMake(customFrame.origin.x, customFrame.origin.y, 0, 0);
            break;
        case UIPopupAnimationTopCenter:
            tempFrame = CGRectMake(customFrame.origin.x, customFrame.origin.y, customFrame.size.width, 1);
            break;
        case UIPopupAnimationTopRight:
            tempFrame = CGRectMake(customFrame.origin.x + customFrame.size.width, customFrame.origin.y, 0, 0);
            break;
        case UIPopupAnimationCenterLeft:
            tempFrame = CGRectMake(customFrame.origin.x, customFrame.origin.y, 1, customFrame.size.height);
            break;
        case UIPopupAnimationCenter:
            tempFrame = CGRectMake(customFrame.origin.x+customFrame.size.width / 2, customFrame.origin.y+customFrame.size.height / 2, 0, 0);
            break;
        case UIPopupAnimationCenterRight:
            tempFrame = CGRectMake(customFrame.origin.x+customFrame.size.width, customFrame.origin.y, 1, customFrame.size.height);
            break;
        case UIPopupAnimationBottomLeft:
            tempFrame = CGRectMake(customFrame.origin.x, customFrame.origin.y+customFrame.size.height, 0, 0);
            break;
        case UIPopupAnimationBottomCenter:
            tempFrame = CGRectMake(customFrame.origin.x, customFrame.origin.y+customFrame.size.height, customFrame.size.width, 1);
            break;
        case UIPopupAnimationBottomRight:
            tempFrame = CGRectMake(customFrame.origin.x + customFrame.size.width, customFrame.origin.y+customFrame.size.height, 0, 0);
            break;
        default:
            break;
    }
    
    if (_animationType != UIPopupAnimationNone) {
        [self.backgroundView addSubview:self.customView];
        CGFloat alpha = 1;
        if (_supportAnimateAlpha) {
            alpha = 0;
        }
        
        NSMutableArray *rectArray = [NSMutableArray new];
        [self.customView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSValue *value = [NSValue valueWithCGRect:obj.frame];
            [rectArray addObject:value];
            obj.alpha = alpha;
            obj.frame = CGRectZero;
        }];
        
        self.customView.alpha = alpha;
        self.customView.frame = tempFrame;
        [UIView animateWithDuration:_animationDuration animations:^{
            self.customView.alpha = 1;
            self.customView.frame = customFrame;
            
            [self.customView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGRect subRect = [rectArray[idx] CGRectValue];
                obj.alpha = 1;
                obj.frame = subRect;
            }];
            
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self.backgroundView addSubview:self.customView];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_supportDismissForClickBackground) {
        _supportDismissForClickBackground = NO;
        [self goBack];
    }
}

// Manager退出的接口
- (void)goBack
{
    _supportDismissForClickBackground = NO;
    // 移除视图
    CGRect customFrame = _customView.frame;
    CGRect tempFrame;
    switch (_animationType) {
        case UIPopupAnimationNone:
            tempFrame = customFrame;
            break;
        case UIPopupAnimationTopLeft:
            tempFrame = CGRectMake(customFrame.origin.x, customFrame.origin.y, 0, 0);
            break;
        case UIPopupAnimationTopCenter:
            tempFrame = CGRectMake(customFrame.origin.x, customFrame.origin.y, customFrame.size.width, 1);
            break;
        case UIPopupAnimationTopRight:
            tempFrame = CGRectMake(customFrame.origin.x + customFrame.size.width, customFrame.origin.y, 0, 0);
            break;
        case UIPopupAnimationCenterLeft:
            tempFrame = CGRectMake(customFrame.origin.x, customFrame.origin.y, 1, customFrame.size.height);
            break;
        case UIPopupAnimationCenter:
            tempFrame = CGRectMake(customFrame.origin.x+customFrame.size.width / 2, customFrame.origin.y+customFrame.size.height / 2, 0, 0);
            break;
        case UIPopupAnimationCenterRight:
            tempFrame = CGRectMake(customFrame.origin.x+customFrame.size.width, customFrame.origin.y, 1, customFrame.size.height);
            break;
        case UIPopupAnimationBottomLeft:
            tempFrame = CGRectMake(customFrame.origin.x, customFrame.origin.y+customFrame.size.height, 0, 0);
            break;
        case UIPopupAnimationBottomCenter:
            tempFrame = CGRectMake(customFrame.origin.x, customFrame.origin.y+customFrame.size.height, customFrame.size.width, 1);
            break;
        case UIPopupAnimationBottomRight:
            tempFrame = CGRectMake(customFrame.origin.x + customFrame.size.width, customFrame.origin.y+customFrame.size.height, 0, 0);
            break;
        default:
            break;
    }
    if (_animationType != UIPopupAnimationNone) {
        __weak typeof(self) weakself = self;
        [UIView animateWithDuration:_animationDuration animations:^{
            if (weakself.supportAnimateAlpha) {
                weakself.customView.alpha = 0;
            }
            self.customView.frame = tempFrame;
            [self.customView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (weakself.supportAnimateAlpha) {
                    obj.alpha = 0;
                }
                obj.frame = CGRectZero;
            }];
        } completion:^(BOOL finished) {
            [weakself.customView removeFromSuperview];
            [weakself.backgroundView removeFromSuperview];
        }];
    } else {
        [self.customView removeFromSuperview];
        [_backgroundView removeFromSuperview];
    }
}

- (void)dealloc
{
    if (_dismissBlock) {
        _dismissBlock();
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
