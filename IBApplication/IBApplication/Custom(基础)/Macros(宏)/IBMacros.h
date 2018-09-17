//
//  IBMacros.h
//  IBApplication
//
//  Created by Bowen on 2018/6/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#ifndef IBMacros_h
#define IBMacros_h

//获取系统对象
#define kApplication        [UIApplication sharedApplication]
#define kAppWindow          [UIApplication sharedApplication].keyWindow
#define kAppDelegate        [AppDelegate shareAppDelegate]
#define kRootController     [UIApplication sharedApplication].delegate.window.rootViewController
#define kUserDefaults       [NSUserDefaults standardUserDefaults]
#define kNotificationCenter [NSNotificationCenter defaultCenter]
#define kFileManager        [NSFileManager defaultManager]

//拼接字符串
#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

//范围随机数
#define IBRandom(from, to) (int)(from + (arc4random() % (to - from + 1)))

//弧度转化成角度
#define kRadianToDegree(radian) ((radian) * (180.0 / M_PI))

//角度转化成弧度
#define kDegreeToRadian(angle) ((angle) / 180.0 * M_PI)

//加载图片简化
#define kImage(Name)       ([UIImage imageNamed:Name])
#define kImageOfFile(Name) ([UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:Name ofType:nil]])

//字体简化
#define kFontWithSize(size)     [UIFont systemFontOfSize:size]
#define kBoldFontWithSize(size) [UIFont boldSystemFontOfSize:size]

//空对象处理
#define NSStringNONil(string)   (string ? string : @"")
#define NSDictionaryNONil(dict) (dict ? dict : @{})
#define NSArrayNONil(array)     (array ? array : @[])

#define kIsNull(obj) ([obj isKindOfClass:[NSNull class]])

#define kIsEmptyArray(a)  (a == nil || ![a isKindOfClass:[NSArray class]] || a.count == 0)
#define kIsEmptyDict(d)   (d == nil || [d isKindOfClass:[NSNull class]] || d.allKeys == nil || d.allKeys.count == 0)
#define kIsEmptyString(s) (s == nil || [s isKindOfClass:[NSNull class]] || ([s isKindOfClass:[NSString class]] && s.length == 0))
#define kIsEmptyData(d)   ([d isKindOfClass:[NSNull class]] || d == nil || [d length] < 1)
#define kIsEmptyObject(o) (o == nil || [o isKindOfClass:[NSNull class]])

#define kIsDictionary(d) (d != nil && [d isKindOfClass:[NSDictionary class]])
#define kIsArray(a)      (a != nil && [a isKindOfClass:[NSArray class]])
#define kIsString(s)     (s != nil && [s isKindOfClass:[NSString class]])

// 颜色
///< format：0xFFFFFF
#define k16RGB(rgbValue) k16RGBA(rgbValue, 1.0)
#define k16RGBA(rgbValue, alphaValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:alphaValue]

///< format：22,22,22,0.5
#define kRGB(r, g, b) kRGBA(r, g, b, a)
#define kRGBA(r, g, b, a) ([UIColor colorWithRed:(r) / 255.0  \
green:(g) / 255.0  \
blue:(b) / 255.0  \
alpha:(a)])

//线程处理
#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

#define dispatch_main_sync_safe(block)            \
if ([NSThread isMainThread]) {                    \
block();                                          \
} else {                                          \
dispatch_sync(dispatch_get_main_queue(), block);  \
}

//日志打印
#ifdef DEBUG
#define NSLogger(format, ...) printf("%s %s\n", __FUNCTION__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String])
#else
#define NSLogger(...)
#endif

//循环引用
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##object = object;
        #else
        #define weakify(object) autoreleasepool{} __block __typeof__(object) block##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##object = object;
        #else
        #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##object;
        #else
        #define strongify(object) autoreleasepool{} __typeof__(object) object = block##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) object = weak##object;
        #else
        #define strongify(object) try{} @finally{} __typeof__(object) object = block##object;
        #endif
    #endif
#endif


#endif /* IBMacros_h */
