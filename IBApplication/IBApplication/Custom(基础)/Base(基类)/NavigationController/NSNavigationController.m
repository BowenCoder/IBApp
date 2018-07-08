//
//  NSNavigationController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/7.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSNavigationController.h"
#import "NSNavigationBar.h"

@interface NSNavigationController ()

@end

@implementation NSNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {

    if (self = [super initWithRootViewController:rootViewController]) {
        [self setValue:[[NSNavigationBar alloc] init] forKey:@"navigationBar"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.visibleViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.visibleViewController;
}

@end
