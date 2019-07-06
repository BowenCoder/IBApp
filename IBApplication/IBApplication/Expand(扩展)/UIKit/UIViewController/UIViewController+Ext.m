//
//  UIViewController+Ext.m
//  IBApplication
//
//  Created by Bowen on 2019/6/20.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "UIViewController+Ext.h"
#import "IBMacros.h"

@implementation UIViewController (Ext)

+ (UIViewController *)mb_findBestViewController:(UIViewController *)vc
{
    if (vc.presentedViewController) {
        // Return presented view controller
        return [UIViewController mb_findBestViewController:vc.presentedViewController];
        
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *)vc;
        if (svc.viewControllers.count > 0) {
            return [UIViewController mb_findBestViewController:svc.viewControllers.lastObject];
        } else {
            return vc;
        }
        
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *)vc;
        if (svc.viewControllers.count > 0) {
            return [UIViewController mb_findBestViewController:svc.topViewController];
        } else {
            return vc;
        }
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *)vc;
        if (svc.viewControllers.count > 0) {
            return [UIViewController mb_findBestViewController:svc.selectedViewController];
        } else {
            return vc;
        }
        
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

+ (UIViewController *)mb_currentViewController
{
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (kIsEmptyObject(viewController)) {
        viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    }
    return [UIViewController mb_findBestViewController:viewController];
}
@end
