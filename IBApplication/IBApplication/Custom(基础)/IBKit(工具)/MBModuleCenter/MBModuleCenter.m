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

- (dispatch_queue_t)moduleCenterQueue
{
    static dispatch_queue_t moduleQueue = NULL;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        moduleQueue = dispatch_queue_create("com.bowen.moduleCenterQueue", NULL);
    });
    
    return moduleQueue;
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
    dispatch_async([self moduleCenterQueue], ^{
        if (![self.managers containsObject:protocol] && protocol) {
            [self.managers addObject:protocol];
        }
    });
}

- (void)unregisterModule:(id<MBModuleProtocol>)protocol
{
    dispatch_async([self moduleCenterQueue], ^{
        if ([self.managers containsObject:protocol] && protocol) {
            [self.managers removeObject:protocol];
        }
    });
}

- (void)excuteBlock:(dispatch_block_t)block
{
    dispatch_async([self moduleCenterQueue], ^{
        dispatch_main_async_safe(^{
            block();
        });
    });
}

- (void)module_willLogin
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_willLogin)]) {
                dispatch_main_async_safe(^{
                    [proto module_willLogin];
                });
            }
        }
    });
}

- (void)module_didLogin
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_didLogin)]) {
                dispatch_main_async_safe(^{
                    [proto module_didLogin];
                });
            }
        }
    });
}

- (void)module_willLogout
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_willLogout)]) {
                dispatch_main_async_safe(^{
                    [proto module_willLogout];
                });
            }
        }
    });
}

- (void)module_didLogout
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_didLogin)]) {
                dispatch_main_async_safe(^{
                    [proto module_didLogin];
                });
            }
        }
    });
}

- (void)module_serviceInfoInited
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_serviceInfoInited)]) {
                dispatch_main_async_safe(^{
                    [proto module_serviceInfoInited];
                });
            }
        }
    });
}

#pragma mark - 生命周期

- (void)module_application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_application:willFinishLaunchingWithOptions:)]) {
                dispatch_main_async_safe(^{
                    [proto module_application:application willFinishLaunchingWithOptions:launchOptions];
                });
            }
        }
    });
}

- (void)module_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_application:didFinishLaunchingWithOptions:)]) {
                dispatch_main_async_safe(^{
                    [proto module_application:application didFinishLaunchingWithOptions:launchOptions];
                });
            }
        }
    });
}

- (void)module_applicationWillEnterForeground:(UIApplication *)application
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_applicationWillEnterForeground:)]) {
                dispatch_main_async_safe(^{
                    [proto module_applicationWillEnterForeground:application];
                });
            }
        }
    });
}

- (void)module_applicationDidBecomeActive:(UIApplication *)application
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_applicationDidBecomeActive:)]) {
                dispatch_main_async_safe(^{
                    [proto module_applicationDidBecomeActive:application];
                });
            }
        }
    });
}

- (void)module_applicationWillResignActive:(UIApplication *)application
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_applicationWillResignActive:)]) {
                dispatch_main_async_safe(^{
                    [proto module_applicationWillResignActive:application];
                });
            }
        }
    });
}

- (void)module_applicationDidEnterBackground:(UIApplication *)application
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_applicationDidEnterBackground:)]) {
                dispatch_main_async_safe(^{
                    [proto module_applicationDidEnterBackground:application];
                });
            }
        }
    });
}

- (void)module_applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_applicationDidReceiveMemoryWarning:)]) {
                dispatch_main_async_safe(^{
                    [proto module_applicationDidReceiveMemoryWarning:application];
                });
            }
        }
    });
}

- (void)module_applicationWillTerminate:(UIApplication *)application
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_applicationWillTerminate:)]) {
                dispatch_main_async_safe(^{
                    [proto module_applicationWillTerminate:application];
                });
            }
        }
    });
}

#pragma mark - 其他

- (void)module_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_application:openURL:sourceApplication:annotation:)]) {
                dispatch_main_async_safe(^{
                    [proto module_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
                });
            }
        }
    });
}

- (void)module_application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_application:openURL:options:)]) {
                dispatch_main_async_safe(^{
                    [proto module_application:application openURL:url options:options];
                });
            }
        }
    });
}

- (void)module_application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_application:performFetchWithCompletionHandler:)]) {
                dispatch_main_async_safe(^{
                    [proto module_application:application performFetchWithCompletionHandler:completionHandler];
                });
            }
        }
    });
}

- (void)module_application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_application:performActionForShortcutItem:completionHandler:)]) {
                dispatch_main_async_safe(^{
                    [proto module_application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
                });
            }
        }
    });
}

- (void)module_applicationSignificantTimeChange:(UIApplication *)application
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_applicationSignificantTimeChange:)]) {
                dispatch_main_async_safe(^{
                    [proto module_applicationSignificantTimeChange:application];
                });
            }
        }
    });
}

- (void)module_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_application:handleEventsForBackgroundURLSession:completionHandler:)]) {
                dispatch_main_async_safe(^{
                    [proto module_application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
                });
            }
        }
    });
}

- (void)module_application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)(NSDictionary * __nullable replyInfo))reply
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_application:handleWatchKitExtensionRequest:reply:)]) {
                dispatch_main_async_safe(^{
                    [proto module_application:application handleWatchKitExtensionRequest:userInfo reply:reply];
                });
            }
        }
    });
}

- (void)module_applicationShouldRequestHealthAuthorization:(UIApplication *)application
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_applicationShouldRequestHealthAuthorization:)]) {
                dispatch_main_async_safe(^{
                    [proto module_applicationShouldRequestHealthAuthorization:application];
                });
            }
        }
    });
}

- (void)module_application:(UIApplication *)application handleIntent:(INIntent *)intent completionHandler:(void(^)(INIntentResponse *intentResponse))completionHandler
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_application:handleIntent:completionHandler:)]) {
                dispatch_main_async_safe(^{
                    [proto module_application:application handleIntent:intent completionHandler:completionHandler];
                });
            }
        }
    });
}

#pragma mark - 通知

- (void)module_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
                dispatch_main_async_safe(^{
                    [proto module_application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
                });
            }
        }
    });
}

- (void)module_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_application:didFailToRegisterForRemoteNotificationsWithError:)]) {
                dispatch_main_async_safe(^{
                    [proto module_application:application didFailToRegisterForRemoteNotificationsWithError:error];
                });
            }
        }
    });
}

- (void)module_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if ([proto respondsToSelector:@selector(module_application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
                dispatch_main_async_safe(^{
                    [proto module_application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
                });
            }
        }
    });
}

- (void)module_userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0))
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if([proto respondsToSelector:@selector(module_userNotificationCenter:willPresentNotification:withCompletionHandler:)]) {
                dispatch_main_async_safe(^{
                    [proto module_userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
                });
            }
        }
    });
}

- (void)module_userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0))
{
    dispatch_async([self moduleCenterQueue], ^{
        for (id<MBModuleProtocol> proto in self.managers) {
            if([proto respondsToSelector:@selector(module_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)]) {
                dispatch_main_async_safe(^{
                    [proto module_userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
                });
            }
        }
    });
}

@end
