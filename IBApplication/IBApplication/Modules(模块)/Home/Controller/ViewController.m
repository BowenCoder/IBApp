//
//  ViewController.m
//  IBApplication
//
//  Created by Bowen on 2018/6/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "ViewController.h"
#import "IBMineController.h"
#import "UIView+Ext.h"
#import "UIView+Effect.h"
#import "MBAlertController.h"
#import "MBTableViewController.h"
#import "MBSocketPacketDecode.h"
#import "MBSocketPacketEncode.h"
#import "MBLogger.h"
#import "IBNetworkStatus.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"主界面";
    [IBNetworkStatus shareInstance];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    MBLogD(@"123");
    MBLogI(@"456");
    
    IBMineController *mine = [[IBMineController alloc] init];
    [self.navigationController pushViewController:mine animated:YES];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

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
//    CGFloat contentY = scrollView.contentOffset.y;
//    [self.naviController updateNavBarAlphaWithOffset:contentY range:500];
    
}


@end
