//
//  UIMacros.h
//  IBApplication
//
//  Created by Bowen on 2018/6/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#ifndef UIMacros_h
#define UIMacros_h

#define kIphoneX ({ \
    BOOL isX = NO; \
    if (@available(iOS 11.0, *)) { \
        isX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0; \
    } \
    isX; \
})

//获取屏幕宽高
#define kScreenWidth     [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight    [[UIScreen mainScreen] bounds].size.height
#define kScreenBounds    [[UIScreen mainScreen] bounds]
#define kScreenScale     [[UIScreen mainScreen] scale]

// 一像素线
#define kOnePixelLine (1.f / [UIScreen mainScreen].scale)

// 横向宽度（以iPhone6为标准）
#define kFitWidth(width)      flat(width * (kScreenWidth/667.00))
// 纵向高度
#define kFitHeight(height)    flat(height * (kScreenHeight/375.00))
// point适配
#define CGPointMakeFit(x, y) CGPointMake(kFitWidth(x), kFitHeight(y))
// size适配
#define CGSizeMakeFit(width, height) CGSizeMake(kFitWidth(width), kFitHeight(height))
// rect适配 
#define CGRectMakeFit(x, y, width, height) CGRectMake(kFitWidth(x), kFitHeight(y), kFitWidth(width), kFitHeight(height))
// edge适配
#define UIEdgeInsetsMakeFit(top, left, bottom, right) UIEdgeInsetsMake(kFitHeight(top), kFitWidth(left), kFitHeight(bottom), kFitWidth(right))

// 状态栏高度(iPhoneX:44, 其他:20)
//#define kStatusBarHeight [UIApplication sharedApplication].statusBarHidden ? 0 : [[UIApplication sharedApplication] statusBarFrame].size.height // 不能动态获取，会被热点，定位蓝条影响
#define kStatusBarHeight [UIApplication sharedApplication].statusBarHidden ? 0 : kIphoneX ? 44 : 20

// 导航栏高度
#define kNavBarHeight    44

// 状态栏和导航栏总高度
#define kTopBarHeight          (kStatusBarHeight + kNavBarHeight)

// 顶部安全区域远离高度
#define kSafeAreaTopHeight     kStatusBarHeight

// 底部安全区域远离高度
#define kSafeAreaBottomHeight  (kIphoneX ? 34 : 0)

// TabBar高度
#define kTabBarHeight          49

// barBar加上底部安全区域高度
#define kBottomBarHeight       (kSafeAreaBottomHeight + kTabBarHeight)

// 安全区域高度(包含导航栏和标签栏)
#define kSafeAreaHeight        (kScreenHeight - kSafeAreaTopHeight - kSafeAreaBottomHeight)

// 除去导航栏,屏幕高度
#define kTabSafeAreaHeight     (kSafeAreaHeight - kNavBarHeight)

// 除去标签栏，屏幕高度
#define kNavSafeAreaHeight     (kSafeAreaHeight - kBottomBarHeight)

// 除去状态栏和标签栏，屏幕高度
#define kViewHeight            (kSafeAreaHeight - kNavBarHeight - kBottomBarHeight)


#pragma mark - CGFloat

/**
 *  某些地方可能会将 CGFLOAT_MIN 作为一个数值参与计算（但其实 CGFLOAT_MIN 更应该被视为一个标志位而不是数值），可能导致一些精度问题，所以提供这个方法快速将 CGFLOAT_MIN 转换为 0
 */
CG_INLINE CGFloat
floatMin(CGFloat floatValue) {
    return floatValue == CGFLOAT_MIN ? 0 : floatValue;
}

/**
 *  基于指定的倍数，对传进来的 floatValue 进行像素取整（像素对齐）。
 *  像素对齐：逻辑像素（point）乘以2（2x的视网膜屏） 或3（3x的视网膜屏）得到整数值。
 *  出现像素不对齐的情况，会导致在GPU渲染时，对没对齐的边缘，需要进行插值计算，这个插值计算的过程会有性能损耗
 *  例如传进来 “2.1”，在 2x 倍数下会返回 2.5（0.5pt 对应 1px），在 3x 倍数下会返回 2.333（0.333pt 对应 1px）。
 */
CG_INLINE CGFloat
flatSpecificScale(CGFloat floatValue, CGFloat scale) {
    floatValue = floatMin(floatValue);
    scale = scale ?: kScreenScale;
    CGFloat flattedValue = ceil(floatValue * kScreenScale) / kScreenScale;
    return flattedValue;
}

/**
 *  基于当前设备的屏幕倍数，对传进来的 floatValue 进行像素取整。
 *  https://www.jianshu.com/p/432fea0232b8
 *  注意如果在 Core Graphic 绘图里使用时，要注意当前画布的倍数是否和设备屏幕倍数一致，若不一致，不可使用 flat() 函数，而应该用 flatSpecificScale
 */
CG_INLINE CGFloat
flat(CGFloat floatValue) {
    return flatSpecificScale(floatValue, 0);
}

/**
 *  调整给定的某个 CGFloat 值的小数点精度，超过精度的部分按四舍五入处理。
 *
 *  例如 CGFloatToFixed(0.3333, 2) 会返回 0.33，而 CGFloatToFixed(0.6666, 2) 会返回 0.67
 *
 *  @warning 参数类型为 CGFloat，也即意味着不管传进来的是 float 还是 double 最终都会被强制转换成 CGFloat 再做计算
 *  @warning 该方法无法解决浮点数精度运算的问题
 */
CG_INLINE CGFloat
CGFloatToFixed(CGFloat value, NSUInteger precision) {
    NSString *formatString = [NSString stringWithFormat:@"%%.%@f", @(precision)];
    NSString *toString = [NSString stringWithFormat:formatString, value];
#if CGFLOAT_IS_DOUBLE
    CGFloat result = [toString doubleValue];
#else
    CGFloat result = [toString floatValue];
#endif
    return result;
}

/// 检测某个数值如果为 NaN 则将其转换为 0，避免布局中出现 crash
CG_INLINE CGFloat
CGFloatSafeValue(CGFloat value) {
    return isnan(value) ? 0 : value;
}

#endif /* UIMacros_h */
