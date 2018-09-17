//
//  UIMacros.h
//  IBApplication
//
//  Created by Bowen on 2018/6/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#ifndef UIMacros_h
#define UIMacros_h

#define IPHONEX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

//获取屏幕宽高
#define kScreenWidth     [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight    [[UIScreen mainScreen] bounds].size.height
#define kScreenBounds    [[UIScreen mainScreen] bounds]

//一像素线
#define kOnePixelLine (1.f / [UIScreen mainScreen].scale)


//横向宽度（以iPhone6为标准）
#define kFitWidth(width)      (kScreenWidth  * (width/667.00))
//纵向高度
#define kFitHeight(height)    (kScreenHeight * (height/375.00))

// 状态栏高度(iPhoneX:44, 其他:20)
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height

// 导航栏高度
#define kNavBarHeight    44

// 状态栏和导航栏总高度
#define kTopBarHeight          (kStatusBarHeight + kNavBarHeight)

// 顶部安全区域远离高度
#define kSafeAreaTopHeight     kStatusBarHeight

// 底部安全区域远离高度
#define kSafeAreaBottomHeight  (IPHONEX ? 34 : 0)

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


#endif /* UIMacros_h */
