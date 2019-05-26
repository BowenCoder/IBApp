//
//  MBModuleProtocol.h
//  IBApplication
//
//  Created by Bowen on 2019/5/26.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol MBModuleProtocol <NSObject>

@optional

/**
 将要登录
 */
- (void)module_willLogin;

/**
 已经登录
 */
- (void)module_didLogin;

/**
 即将退出 （当前还能获取到当前登录用户的信息）
 */
- (void)module_willLogout;

/**
 已经登出
 */
- (void)module_didLogout;

/**
 serviceInfo初始化成功
 */
- (void)module_serviceInfoInited;

#pragma mark - 生命周期

- (void)module_application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions;

- (void)module_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (void)module_applicationWillEnterForeground:(UIApplication *)application;

- (void)module_applicationDidBecomeActive:(UIApplication *)application;

- (void)module_applicationWillResignActive:(UIApplication *)application;

- (void)module_applicationDidEnterBackground:(UIApplication *)application;

- (void)module_applicationDidReceiveMemoryWarning:(UIApplication *)application;

- (void)module_applicationWillTerminate:(UIApplication *)application;

#pragma mark - 其他

- (void)module_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation;

- (void)module_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;

- (void)module_application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

- (void)module_application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler;

- (void)module_applicationSignificantTimeChange:(UIApplication *)application;

- (void)module_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler;

- (void)module_application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)(NSDictionary * __nullable replyInfo))reply;

- (void)module_applicationShouldRequestHealthAuthorization:(UIApplication *)application;

- (void)module_application:(UIApplication *)application handleIntent:(INIntent *)intent completionHandler:(void(^)(INIntentResponse *intentResponse))completionHandler;

#pragma mark - 通知

- (void)module_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

- (void)module_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

- (void)module_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

- (void)module_userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0));

- (void)module_userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0));

@end

NS_ASSUME_NONNULL_END
