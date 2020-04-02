//
//  AppDelegate.m
//  IBApplication
//
//  Created by Bowen on 2018/6/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "AppDelegate.h"
#import "IBApp.h"
#import "ViewController.h"
#import "MBDebug.h"
#import "IBNaviController.h"
#import "MBTabBarController.h"
#import "IBSocialManager.h"
#import "MBLaunchManager.h"
#import "MBLogger.h"
#import "MBModuleCenter.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[MBLaunchManager sharedInstance] willFinishLaunching:launchOptions];
    [[MBModuleCenter defaultCenter] module_application:application willFinishLaunchingWithOptions:launchOptions];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[IBSocialManager manager] registerSDK:IBSocialPlatformQQ];
    [[IBSocialManager manager] registerSDK:IBSocialPlatformWechat];
    [[IBSocialManager manager] registerSDK:IBSocialPlatformSina];
    
    self.window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    ViewController *vc = [[ViewController alloc] init];
    vc.tabBarItem.title = @"首页";
    vc.tabBarItem.image = [UIImage imageNamed:@"icon_tabbar_subscription_no"];

    MBTabBarController *tab = [[MBTabBarController alloc] init];
    IBNaviController *nav = [[IBNaviController alloc] initWithRootViewController:vc naviBar:[IBNaviBar class]];
    
    [tab addChildViewController: nav];

    self.window.rootViewController = tab;
    [self.window makeKeyAndVisible];
    [MBDebug openFPS];

    [IBApp onFirstStartForVersion:APP_VERSION block:^(BOOL isFirstStartForVersion) {
        if (isFirstStartForVersion) {
            NSLog(@"特性");
        } else {
            NSLog(@"闪屏");
        }
    }];
    [[MBLaunchManager sharedInstance] didFinishLaunching:launchOptions];
    [[MBModuleCenter defaultCenter] module_application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    [[MBModuleCenter defaultCenter] module_application:app openURL:url options:options];
    return [[IBSocialManager manager] openURL:url application:nil annotation:options];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    MBTraceStack;
    [[MBModuleCenter defaultCenter] module_applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    MBTraceStack;
    __block UIBackgroundTaskIdentifier taskId = [application beginBackgroundTaskWithExpirationHandler:^{
        taskId = UIBackgroundTaskInvalid;
        [application endBackgroundTask:taskId];
    }];
    [[MBModuleCenter defaultCenter] module_applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    MBTraceStack;
    [[MBModuleCenter defaultCenter] module_applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    MBTraceStack;
    [[MBModuleCenter defaultCenter] module_applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    MBTraceStack;
    [[MBModuleCenter defaultCenter] module_applicationWillTerminate:application];
}


@end
