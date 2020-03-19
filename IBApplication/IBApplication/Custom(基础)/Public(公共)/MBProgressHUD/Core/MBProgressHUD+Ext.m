//
//  MBProgressHUD+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBProgressHUD+Ext.h"
#import "IBImage.h"
#import "UIImage+GIF.h"
#import "MBEmptyView.h"
#import "MBLoadingView.h"

CGFloat const delayTime = 1.2;

typedef NS_ENUM(NSInteger, MBStyle) {
    MBStyleDefault = 0,//MBProgressHUD默认的风格
    MBStyleBlack   = 1,//黑底白字
    MBStyleGif     = 2,
    MBStyleCustom  = 3,//:自定义风格<由自己设置自定义风格的颜色>
};

@implementation MBProgressHUD (Ext)

#pragma mark - Toast

NS_INLINE MBProgressHUD *setup(UIView *view, NSString *title, MBStyle style,BOOL autoHidden) {
    
    if (view == nil) {
        view = [UIApplication sharedApplication].delegate.window;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    //配置hud样式
    setupStyle(hud, style);
    //文字
    hud.label.text = title;
    //支持多行
    hud.label.numberOfLines = 0;
    //隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    if (autoHidden) {
        // x秒之后消失
        [hud hideAnimated:YES afterDelay:delayTime];
    }
    
    return hud;
}

NS_INLINE void setupStyle(MBProgressHUD *hud, MBStyle style) {
    switch (style) {
        case MBStyleDefault:
            break;
        case MBStyleBlack:
            hud.bezelView.backgroundColor = [UIColor blackColor];
            hud.contentColor = [UIColor whiteColor];
            break;
        case MBStyleGif:
            hud.backgroundView.backgroundColor = [UIColor whiteColor];
            hud.bezelView.backgroundColor = [UIColor whiteColor];
            break;
        case MBStyleCustom:
            hud.backgroundView.backgroundColor = [UIColor whiteColor];
            hud.bezelView.backgroundColor = [UIColor blackColor];
            hud.contentColor = [UIColor whiteColor];
            break;
        default:
            break;
    }
}

NS_INLINE void setupPosition(MBProgressHUD *hud, MBPosition position) {
    switch (position) {
        case MBPositionTop:
            hud.offset = CGPointMake(0.f, -MBProgressMaxOffset);
            break;
        case MBPositionCenter:
            hud.offset = CGPointMake(0.f, 0.f);
            break;
        case MBPositionBottom:
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            break;
        default:
            break;
    }
}

+ (MBProgressHUD *)showLoading:(UIView *)superview {
    MBProgressHUD *hud = setup(superview, nil, MBStyleBlack, NO);
    hud.square = YES;
    return hud;
}

+ (MBProgressHUD *)showLoading:(UIView *)superview text:(NSString *)text {
    MBProgressHUD *hud = setup(superview, text, MBStyleBlack, NO);
    hud.square = YES;
    return hud;
}

+ (MBProgressHUD *)showLoading:(UIView *)superview text:(NSString *)text background:(UIColor *)color {
    MBProgressHUD *hud = setup(superview, text, MBStyleCustom, NO);
    hud.square = YES;
    if (color) {
        hud.backgroundView.backgroundColor = color;
    }
    return hud;
}

+ (MBProgressHUD *)showCustom:(UIView *)superview view:(UIView *)view text:(NSString *)text {
    MBProgressHUD *hud = setup(superview, text, MBStyleBlack, NO);
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = view;
    hud.square = YES;
    return hud;
}

+ (MBProgressHUD *)showLoadingGif:(UIView *)superview gif:(NSData *)data text:(NSString *)text {
    MBProgressHUD *hud = setup(superview, text, MBStyleGif, NO);
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *image = [UIImage sd_animatedGIFWithData:data];
    UIImageView *gif = [[UIImageView alloc] initWithImage:image];
    hud.customView = gif;
    hud.square = YES;
    return hud;
}

/** 纯文字 */
+ (void)showText:(UIView *)superview title:(NSString *)title position:(MBPosition)position {
    MBProgressHUD *hud = setup(superview, title, MBStyleBlack, YES);
    hud.mode = MBProgressHUDModeText;
    setupPosition(hud, position);
}

/** 纯文字标题 + 详情 */
+ (void)showText:(UIView *)superview title:(NSString *)title detail:(NSString *)detail position:(MBPosition)position {
    MBProgressHUD *hud = setup(superview, title, MBStyleBlack, YES);
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabel.text = detail;
    setupPosition(hud, position);
}

+ (void)showSuccess:(UIView *)superview title:(NSString *)title {
    MBProgressHUD *hud = setup(superview, title, MBStyleBlack, YES);
    hud.mode = MBProgressHUDModeCustomView;
    hud.square = YES;
    hud.customView = [[UIImageView alloc] initWithImage:[IBImage imageWithName:@"success" inBundle:@"MBProgressHUD"]];
}

+ (void)showError:(UIView *)superview title:(NSString *)title {
    MBProgressHUD *hud = setup(superview, title, MBStyleBlack, YES);
    hud.mode = MBProgressHUDModeCustomView;
    hud.square = YES;
    hud.customView = [[UIImageView alloc] initWithImage:[IBImage imageWithName:@"error" inBundle:@"MBProgressHUD"]];
}

+ (MBProgressHUD *)showProgress:(UIView *)superview title:(NSString *)title detail:(NSString *)detail progress:(void(^)(MBProgressHUD *hud))callback mode:(MBProgressBarMode)mode {
    MBProgressHUD *hud = setup(superview, title, MBStyleBlack, NO);
    hud.detailsLabel.text = detail;
    hud.square = YES;
    if (mode == MBProgressModeDeterminate) {
        hud.mode = MBProgressHUDModeDeterminate;
    } else if (mode == MBProgressModeAnnularDeterminate) {
        hud.mode = MBProgressHUDModeAnnularDeterminate;
    } else {
        hud.mode = MBProgressModeHorizontalBar;
    }
    callback(hud);
    return hud;
}

+ (void)hideHUDForView:(UIView *)view {
    if (view == nil) {
        view = [UIApplication sharedApplication].delegate.window;
    }
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD {
    [self hideHUDForView:nil];
}

#pragma mark - Loading

+ (void)showBallLoadingView:(UIView *)superview {
    
    [self hideBallLoadingView:superview];
    MBBallLoadingView *loadingView = [[MBBallLoadingView alloc] initWithFrame:superview.frame];
    [loadingView startAnimation];
    [superview addSubview:loadingView];
}

+ (void)hideBallLoadingView:(UIView *)superview {
    
    NSEnumerator *subviewsEnum = [superview.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass: [MBBallLoadingView class]]) {
            MBBallLoadingView *loadingView = (MBBallLoadingView *)subview;
            [loadingView stopAnimation];
            [loadingView removeFromSuperview];
            break;
        }
    }
}

+ (void)showCircleLoadingView:(UIView *)superview {
    
    [self hideCircleLoadingView:superview];
    MBCircleLoadingView *circle = [[MBCircleLoadingView alloc] initWithFrame:superview.frame];
    circle.lineWidth = 2;
    circle.colorArray = @[[UIColor redColor], [UIColor purpleColor], [UIColor blueColor]].mutableCopy;
    [superview addSubview:circle];
    [circle startAnimation];
}

+ (void)hideCircleLoadingView:(UIView *)superview {
    
    NSEnumerator *subviewsEnum = [superview.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass: [MBCircleLoadingView class]]) {
            MBCircleLoadingView *loadingView = (MBCircleLoadingView *)subview;
            [loadingView stopAnimation];
            [loadingView removeFromSuperview];
            break;
        }
    }
}

+ (void)showTriangleLoadingView:(UIView *)superview {
    
    [MBProgressHUD hideCircleLoadingView:superview];
    MBTriangleLoadingView *tri = [[MBTriangleLoadingView alloc] initWithFrame:superview.frame];
    [tri startAnimation];
    [superview addSubview:tri];
}

+ (void)hideTriangleLoadingView:(UIView *)superview {
    
    NSEnumerator *subviewsEnum = [superview.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass: [MBTriangleLoadingView class]]) {
            MBTriangleLoadingView *loadingView = (MBTriangleLoadingView *)subview;
            [loadingView stopAnimation];
            [loadingView removeFromSuperview];
            break;
        }
    }
}

+ (void)showSwapLoadingView:(UIView *)superview {
    
    [MBProgressHUD hideSwapLoadingView:superview];
    MBSwapLoadingView *swap = [[MBSwapLoadingView alloc] initWithFrame:superview.frame];
    [swap startAnimation];
    [superview addSubview:swap];
}

+ (void)hideSwapLoadingView:(UIView *)superview {
    
    NSEnumerator *subviewsEnum = [superview.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass: [MBSwapLoadingView class]]) {
            MBSwapLoadingView *loadingView = (MBSwapLoadingView *)subview;
            [loadingView stopAnimation];
            [loadingView removeFromSuperview];
            break;
        }
    }
}

@end

