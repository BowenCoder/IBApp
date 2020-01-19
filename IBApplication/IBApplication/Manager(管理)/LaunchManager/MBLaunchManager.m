//
//  MBLaunchManager.m
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBLaunchManager.h"
#import "MBLaunchSetup.h"
#import "MBModuleCenter.h"
#import "MBUserManager.h"

@interface MBLaunchManager ()

@property (nonatomic, strong) UINavigationController *navController;

@end

@implementation MBLaunchManager

+ (MBLaunchManager *)sharedInstance
{
    static MBLaunchManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[MBLaunchManager alloc] init];
        }
    });
    return _instance;
}

- (void)willFinishLaunching:(NSDictionary *)launchOptions
{
    [MBLaunchSetup loggerSetup];
    [MBLaunchSetup userSetup];
    [MBLaunchSetup moduleSetup];
}

- (void)didFinishLaunching:(NSDictionary *)launchOptions
{
    [self initLib];
    [self launchVC];
}

- (void)initLib
{
    [MBLaunchSetup buglySetup];
    [MBLaunchSetup routerSetup];
    [MBLaunchSetup shareSetup];
    [MBLaunchSetup trackSetup];
    [MBLaunchSetup WKWebViewSetup];
}

- (void)launchVC
{
//    [self loadWindow];
    BOOL isLogin;
    if (!isLogin) {
        
    } else {
        
    }
}

- (void)loadWindow {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].delegate.window = window;
    [window makeKeyAndVisible];
}

- (void)setupRootVC:(UIViewController *)rootVC {
    self.navController = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [UIApplication sharedApplication].keyWindow.rootViewController = self.navController;
}

- (void)pushViewController:(UIViewController *)vc animated:(BOOL)animated
{
    if ([vc isKindOfClass:UIViewController.class]) {
        [self.navController pushViewController:vc animated:animated];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    return [self.navController popViewControllerAnimated:animated];
}

- (UIViewController *)popViewControllerWithLevel:(NSInteger)level animated:(BOOL)animated
{
    NSArray *viewControls = self.navController.viewControllers;
    if (level > 1 &&
        viewControls.count > 1) {
        NSInteger lastIndex = viewControls.count - 1;
        UIViewController *to = self.navController.viewControllers.firstObject;
        if (level >= lastIndex) {
            [self.navController popToRootViewControllerAnimated:animated];
        } else {
            NSInteger toIndex = lastIndex - level;
            to = [viewControls objectAtIndex:toIndex];
            [self.navController popToViewController:to animated:YES];
        }
        return to;
    }
    else{
        return [self popViewControllerAnimated:YES];
    }
}

- (BOOL)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion
{
    if ([vc isKindOfClass:[UIViewController class]]) {
        [self.navController presentViewController:vc animated:animated completion:completion];
        return YES;
    }
    return NO;
}


- (void)loginAccount
{
    [[MBModuleCenter defaultCenter] module_willLogin];
    
    // 网络请求
    
    [[MBModuleCenter defaultCenter] module_didLogin];
}

- (void)logoutAccount
{
    [[MBModuleCenter defaultCenter] module_willLogout];
    
    // 网络请求
    [[MBUserManager sharedManager] logout];
    [[MBModuleCenter defaultCenter] module_didLogout];
}

- (void)checkAppUpdateWithshowOption:(BOOL)showOption
{
    
}

- (void)uploadUserDeviceInfo
{
    
}

-(void)checkBlack
{
    
}

@end
