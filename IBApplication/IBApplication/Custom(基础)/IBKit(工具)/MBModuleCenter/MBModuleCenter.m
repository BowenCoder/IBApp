//
//  MBModuleCenter.m
//  IBApplication
//
//  Created by Bowen on 2019/5/26.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBModuleCenter.h"
#import "IBMacros.h"

@interface MBModuleCenter ()

@property (nonatomic, strong) NSMutableArray<id<MBModuleProtocol>> *managers;

@end

@implementation MBModuleCenter

+ (instancetype)defaultCenter
{
    static MBModuleCenter *center;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!center) {
            center = [[MBModuleCenter alloc] init];
        }
    });
    return center;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _managers = [NSMutableArray array];
    }
    return self;
}

- (void)registerModule:(id<MBModuleProtocol>)protocol
{
    dispatch_main_sync_safe(^{
        if (protocol && ![self.managers containsObject:protocol]) {
            [self.managers addObject:protocol];
        }
    });
}

- (void)unregisterModule:(id<MBModuleProtocol>)protocol
{
    dispatch_main_sync_safe(^{
        if (protocol && [self.managers containsObject:protocol]) {
            [self.managers removeObject:protocol];
        }
    });
}

- (void)excuteBlock:(dispatch_block_t)block
{
    dispatch_main_async_safe(block);
}

- (void)module_willLogin
{
    dispatch_main_async_safe(^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_willLogin)]) {
                [proto module_willLogin];
            }
        }
    });
}

- (void)module_didLogin
{
    dispatch_main_async_safe(^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_didLogin)]) {
                [proto module_didLogin];
            }
        }
    });
}

- (void)module_willLogout
{
    dispatch_main_async_safe(^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_willLogout)]) {
                [proto module_willLogout];
            }
        }
    });
}

- (void)module_didLogout
{
    dispatch_main_async_safe(^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_didLogin)]) {
                [proto module_didLogin];
            }
        }
    });
}

- (void)module_serviceInfoInited
{
    dispatch_main_async_safe(^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_serviceInfoInited)]) {
                [proto module_serviceInfoInited];
            }
        }
    });
}

#pragma mark - 生命周期

- (void)module_application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_application:willFinishLaunchingWithOptions:)]) {
            [proto module_application:application willFinishLaunchingWithOptions:launchOptions];
        }
    }
}

- (void)module_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_application:didFinishLaunchingWithOptions:)]) {
            [proto module_application:application didFinishLaunchingWithOptions:launchOptions];
        }
    }
}

- (void)module_applicationWillEnterForeground:(UIApplication *)application
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_applicationWillEnterForeground:)]) {
            [proto module_applicationWillEnterForeground:application];
        }
    }
}

- (void)module_applicationDidBecomeActive:(UIApplication *)application
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_applicationDidBecomeActive:)]) {
            [proto module_applicationDidBecomeActive:application];
        }
    }
}

- (void)module_applicationWillResignActive:(UIApplication *)application
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_applicationWillResignActive:)]) {
            [proto module_applicationWillResignActive:application];
        }
    }
}

- (void)module_applicationDidEnterBackground:(UIApplication *)application
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_applicationDidEnterBackground:)]) {
            [proto module_applicationDidEnterBackground:application];
        }
    }
}

- (void)module_applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_applicationDidReceiveMemoryWarning:)]) {
            [proto module_applicationDidReceiveMemoryWarning:application];
        }
    }
}

- (void)module_applicationWillTerminate:(UIApplication *)application
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_applicationWillTerminate:)]) {
            [proto module_applicationWillTerminate:application];
        }
    }
}

#pragma mark - 其他

- (void)module_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_application:openURL:sourceApplication:annotation:)]) {
            [proto module_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
        }
    }
}

- (void)module_application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_application:openURL:options:)]) {
            [proto module_application:application openURL:url options:options];
        }
    }
}

- (void)module_application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_application:performFetchWithCompletionHandler:)]) {
            [proto module_application:application performFetchWithCompletionHandler:completionHandler];
        }
    }
}

- (void)module_application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_application:performActionForShortcutItem:completionHandler:)]) {
            [proto module_application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
        }
    }
}

- (void)module_applicationSignificantTimeChange:(UIApplication *)application
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_applicationSignificantTimeChange:)]) {
            [proto module_applicationSignificantTimeChange:application];
        }
    }
}

- (void)module_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_application:handleEventsForBackgroundURLSession:completionHandler:)]) {
            [proto module_application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
        }
    }
}

- (void)module_application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)(NSDictionary * __nullable replyInfo))reply
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_application:handleWatchKitExtensionRequest:reply:)]) {
            [proto module_application:application handleWatchKitExtensionRequest:userInfo reply:reply];
        }
    }
}

- (void)module_applicationShouldRequestHealthAuthorization:(UIApplication *)application
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_applicationShouldRequestHealthAuthorization:)]) {
            [proto module_applicationShouldRequestHealthAuthorization:application];
        }
    }
}

- (void)module_application:(UIApplication *)application handleIntent:(INIntent *)intent completionHandler:(void(^)(INIntentResponse *intentResponse))completionHandler
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_application:handleIntent:completionHandler:)]) {
            [proto module_application:application handleIntent:intent completionHandler:completionHandler];
        }
    }
}

#pragma mark - 通知

- (void)module_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
            [proto module_application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
        }
    }
}

- (void)module_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_application:didFailToRegisterForRemoteNotificationsWithError:)]) {
            [proto module_application:application didFailToRegisterForRemoteNotificationsWithError:error];
        }
    }
}

- (void)module_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if ([proto respondsToSelector:@selector(module_application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
            [proto module_application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
        }
    }
}

- (void)module_userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0))
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if([proto respondsToSelector:@selector(module_userNotificationCenter:willPresentNotification:withCompletionHandler:)]) {
            [proto module_userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
        }
    }
}

- (void)module_userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0))
{
    for (id<MBModuleProtocol> proto in self.managers) {
        if([proto respondsToSelector:@selector(module_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)]) {
            [proto module_userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
        }
    }
}

@end
