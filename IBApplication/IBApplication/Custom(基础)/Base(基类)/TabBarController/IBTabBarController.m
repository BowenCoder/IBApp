//
//  IBTabBarController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/9.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBTabBarController.h"

@interface IBTabBarController ()

@end

@implementation IBTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 控制屏幕旋转
- (BOOL)shouldAutorotate {
    UIViewController *vc = self.selectedViewController;
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)vc shouldAutorotate];
    }
    return vc.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *vc = self.selectedViewController;
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)vc supportedInterfaceOrientations];
    }
    return vc.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *vc = self.selectedViewController;
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)vc preferredInterfaceOrientationForPresentation];
    }
    return vc.preferredInterfaceOrientationForPresentation;
}


@end
