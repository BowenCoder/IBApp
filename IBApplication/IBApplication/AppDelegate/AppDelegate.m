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
#import "IBDebug.h"
#import "IBNaviController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    ViewController *vc = [[ViewController alloc] init];
    UITabBarController *tab = [[UITabBarController alloc] init];
//    IBNaviController *nav = [[IBNaviController alloc] initWithRootViewController:vc];
    IBNaviController *nav = [[IBNaviController alloc] initWithRootViewController:vc naviBar:[IBNaviBar class]];
    nav.naviBar.lucencyBar = YES;
    nav.naviBar.globalBarColor = [UIColor redColor];
//    [nav.naviBar hiddenBarBottomLine:YES];
//
////    nav.naviBar.globalShadowImage = [UIImage new];
//    nav.naviBar.globalBarTintColor = [UIColor redColor];
//    nav.naviBar.globalTintColor = [UIColor purpleColor];
     
    [IBNaviBar setTitleColor:[UIColor redColor] fontSize:16];
    [IBNaviBar setItemTitleColor:[UIColor orangeColor] fontSize:13];
    [tab addChildViewController: nav];


    self.window.rootViewController = tab;
    [self.window makeKeyAndVisible];
    [IBDebug openFPS];

    [IBApp onFirstStartForVersion:APP_VERSION block:^(BOOL isFirstStartForVersion) {
        if (isFirstStartForVersion) {
            NSLog(@"特性");
        } else {
            NSLog(@"闪屏");
        }
    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
