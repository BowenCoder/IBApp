//
//  IBMineController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/5.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBMineController.h"
//#import "UINavigationController+FDFullscreenPopGesture.h"

@interface IBMineController ()<UIGestureRecognizerDelegate>

@end

@implementation IBMineController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadData];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:nil action:nil];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
//    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
//    self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
//    self.navigationController.navigationBar.translucent = YES;
    
//    [self rightBarItemWithTitle:@"关注" titleColor:[UIColor redColor] imageName:@"bubble"];
//    [self rightBarItemWithTitle:@"关注" titleColor:[UIColor redColor] imageName:@"bubble"];
//    [self leftBarItemWithTitle:@"关注" titleColor:[UIColor redColor] imageName:@"bubble"];


}

- (void)rightBarItemClick:(UIButton *)button {
    NSLog(@"%@",button);
}

- (void)reloadData {
    NSString *path=@"https://api.ishowchina.com/v3/search/poi?region=%E5%8C%97%E4%BA%AC&page_num=2&datasource=poi&scope=2&query=%E7%9A%87%E5%86%A0%E5%81%87%E6%97%A5%E9%85%92%E5%BA%97&type=%E9%85%92%E5%BA%97&page_size=3&ts=1514358214000&scode=775a26c87455fa2adbcd4c39336e19f9&ak=ba3b7217a815b3acd6fd7b525f698be0";
    [self pageLoad:path params:nil success:^(id JSON) {
        NSLog(@"%@",JSON);
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    } isGet:NO];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    NSLog(@"%@-%@", gestureRecognizer.delegate, otherGestureRecognizer.delegate);
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
