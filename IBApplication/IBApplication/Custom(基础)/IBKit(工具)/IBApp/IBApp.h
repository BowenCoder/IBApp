//
//  IBApp.h
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]

#define APP_BUILD [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define APP_BUNDLEID [[NSBundle mainBundle] bundleIdentifier]

#define APP_LANGUAGE [[NSLocale preferredLanguages] firstObject]

#define IOS_VERSION [IBApp OSVersion]

NS_ASSUME_NONNULL_BEGIN

@interface IBApp : NSObject

#pragma mark - Basic

/**
 获取keyWindow
 */
- (UIWindow *)keyWindow;

/**
 数字形式的操作系统版本号
 如 10.3.1版本 表示为 103010；根据 iOS 规范，版本号最多可能有3位
 [[[UIDevice currentDevice] systemVersion] doubleValue] 只能获取到二级的版本号
 例如 10.3.1 只会得到 10.3
 */
+ (NSInteger)OSVersion;

/**
 获取随机 UUID 例如 E621E1F8-C36C-495A-93FC-0C247A3E6E5F

 @return 随机 UUID
 */
+ (NSString *)UUID;

/**
 广告商的标志符
 */
+ (NSString *)idfa;

/**
 供应商的标志符
 */
+ (NSString *)idfv;

/**
 APP图标
 
 @return 图片
 */
+ (UIImage *)appIcon;

/**
 震动设备
 */
+ (void)shakeDevice;

/**
 APP缓存(document, caches, temp)

 @return 缓存大小
 */
+ (NSString *)cacheSize;

/**
 清空缓存

 @return 是否清空
 */
+ (BOOL)emptyCaches;

/**
 将APNS的NSData类型token格式化成字符串

 @param tokenData token
 @return token字符串
 */
+ (NSString *)APNSToken:(NSData *)tokenData;

/**
 *  截屏
 *
 *  @return 返回截取的屏幕的图像
 */
+ (UIImage *)screenShot;

/**
 *  截取想要的view生成一张图片
 *
 *  @param view 要截的view
 *
 *  @return 生成的图片
 */
+ (UIImage *)shotView:(UIView *)view bounds:(CGRect)bounds;

/**
 判断是否首次启动，不修改
 
 @param version app版本号，默认为当前版本号
 */
+ (BOOL)isFirstStartForVersion:(NSString * _Nonnull)version;

/**
 判断是否首次启动，修改当前版本号

 @param version app版本号，默认为当前版本号
 @param block 结果回调
 */
+ (void)onFirstStartForVersion:(NSString *)version block:(void (^)(BOOL isFirstStartForVersion))block;

/**
 检查App是否需要更新

 @param appID 账号
 @param block 回调
 */
+ (void)checkAppVersionInStore:(NSString *)appID block:(void(^)(NSString *storeVersion, NSString *openUrl,BOOL update))block;

#pragma mark - Open

/** 可以用来判断设备是否安装app等 */
+ (BOOL)canOpenURL:(NSURL *)url;

/** 打开一个URL(网页或者跳转等) */
+ (void)openURL:(NSURL *)url;

/** 发送邮件 */
+ (void)sendMail:(NSString *)mail;

/** 发送短信 */
+ (void)sendSMS:(NSString *)number;

/** 打电话 */
+ (void)callNumber:(NSString *)number;

+ (void)openSettings;

#pragma mark - Device

/** 判断是否是平板 */
+ (BOOL)isIPad;

/** 判断是否是iPod */
+ (BOOL)isIPod;

/** 判断是否是手机 */
+ (BOOL)isIPhone;

/** 判断是否是模拟器 */
+ (BOOL)isSimulator;

/** 判断是否越狱 */
+ (BOOL)isJailbroken;

/** 设备的机器型号 */
+ (NSString *)machineModel;

/** 电池电量 */
+ (CGFloat)batteryLevel;

/** 无线网ssid */
+ (id)wifiSSID;

/** CPU使用率 */
+ (CGFloat)cpuUsage;

/** CPU频率 */
+ (NSUInteger)cpuFrequency;

/** 总线频率 */
+ (NSUInteger)busFrequency;

/** ram的size */
+ (NSUInteger)ramSize;

/** cpu个数 */
+ (NSUInteger)cpuNumber;

/** 获取手机内存总量, 返回的是字节数 */
+ (NSUInteger)totalMemoryBytes;

/** 获取手机可用内存, 返回的是字节数 */
+ (NSUInteger)freeMemoryBytes;

/** 获取手机硬盘总空间, 返回的是字节数 */
+ (NSUInteger)totalDiskSpaceBytes;

/** 获取手机硬盘空闲空间, 返回的是字节数 */
+ (NSUInteger)freeDiskSpaceBytes;

@end

NS_ASSUME_NONNULL_END
