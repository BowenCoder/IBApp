//
//  IBMineController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/5.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBMineController.h"
//#import "UINavigationController+FDFullscreenPopGesture.h"
#import "IBNaviController.h"
#import "MBPopupArrowView.h"
#import "MBTimerSchedule.h"
#import "IBHTTPManager.h"
#import "MBAutoHeightTextView.h"
#import "Masonry.h"

@interface IBMineController ()<UINavigationControllerDelegate, MBTimerScheduleProtocol>

@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) MBTimerSchedule *schedule;
@property (nonatomic, strong) MBAutoHeightTextView *textView;

@end

@implementation IBMineController

- (void)dealloc
{
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"123";
    [self rightBarItemWithTitle:@"关注" titleColor:nil imageName:nil action:nil];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame= CGRectMake(0, 200, 100, 44);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.btn = btn;
    
//    self.schedule = [[MBTimerSchedule alloc] init];
//    [self.schedule registerSchedule:self];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor redColor];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-300);
        make.left.right.equalTo(self.view);
    }];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.textView = [[MBAutoHeightTextView alloc] initWithDataSource:nil];
    self.textView.cursorColor = [UIColor orangeColor];
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(line).insets(UIEdgeInsetsMake(10, 58, 10, 58));
    }];
        
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)scheduledTrigged:(NSUInteger)timerCounter
{
    NSLog(@"bowen scheduledTrigged %ld", timerCounter);
}

- (void)test {
    MBPopupArrowView *pop = [[MBPopupArrowView alloc] initWithFrame:CGRectMake(0, 0, 250, 100)];
    pop.priority = MBPopupArrowPriorityHorizontal;
    pop.dimBackground = YES;
    pop.offsets = CGPointMake(0, 0);
    pop.preferredArrowDirection = MBPopupArrowDirectionTop;
    pop.translucent = NO;
    pop.translucentStyle = MBPopupArrowStyleDefault;
    pop.preferredWidth = 300.0;
    [pop showFromRect:self.btn.frame inView:self.view animated:YES duration:20];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self reloadData];
}

- (void)rightBarItemClick:(UIButton *)button {
    NSLog(@"%@",button);
}

- (void)reloadData {
    NSString *path=@"https://api.ishowchina.com/v3/search/poi?region=%E5%8C%97%E4%BA%AC&page_num=2&datasource=poi&scope=2&query=%E7%9A%87%E5%86%A0%E5%81%87%E6%97%A5%E9%85%92%E5%BA%97&type=%E9%85%92%E5%BA%97&page_size=3&ts=1514358214000&scode=775a26c87455fa2adbcd4c39336e19f9&ak=ba3b7217a815b3acd6fd7b525f698be0";
    [IBHTTPManager GETRetry:path params:nil completion:^(IBURLErrorCode errorCode, IBURLResponse *response) {
        NSLog(@"");
    }];

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
