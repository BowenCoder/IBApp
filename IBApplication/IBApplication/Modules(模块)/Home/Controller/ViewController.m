//
//  ViewController.m
//  IBApplication
//
//  Created by Bowen on 2018/6/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Ext.h"
#import "IBMineController.h"
#import "MBProgressHUD+Ext.h"
#import "IBEmptyView.h"
#import "NSDate+Ext.h"
#import "IBApp.h"
#import "IBColor.h"
#import "IBNaviBar+Config.h"
#import "AXWebViewController.h"
#import "UIControl+Repeat.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIView *testView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"主界面";

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 100, self.view.frame.size.width, 44);
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    btn.acceptEventInterval = 3;
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    self.config = [[IBNaviConfig alloc] initWithBarOptions:IBNaviBarOptionShow | IBNaviBarOptionColor tintColor:[UIColor orangeColor] backgroundColor:[UIColor redColor] backgroundImage:nil backgroundImgID:nil];
    [self addRefreshHeader];
    [self addRefreshFooter];
}

- (void)test {
    NSLog(@"123");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    
    AXWebViewController *webVC = [[AXWebViewController alloc] initWithAddress:@"https://www.iqiyi.com"];
    webVC.showsToolBar = YES;
     webVC.showsNavigationCloseBarButtonItem = NO;
    if (AX_WEB_VIEW_CONTROLLER_iOS9_0_AVAILABLE()) {
        webVC.webView.allowsLinkPreview = YES;
    }
    [self.navigationController pushViewController:webVC animated:YES];


//    IBMineController *mine = [[IBMineController alloc] init];
//    mine.config = [[IBNaviConfig alloc] initWithBarOptions:IBNaviBarOptionShow|IBNaviBarOptionColor tintColor:[UIColor orangeColor] backgroundColor:[UIColor purpleColor] backgroundImage:nil backgroundImgID:nil];
//    [self.navigationController pushViewController:mine animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 100, 24)];
        tf.borderStyle = UITextBorderStyleBezel;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        [cell addSubview:tf];
    }
    
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentY = scrollView.contentOffset.y;
//    [self.naviController updateNavBarAlphaWithOffset:contentY range:500];
    
}


@end
