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
#import "IBCheckbox.h"
#import "IBPopupManager.h"
#import "IBPopup.h"
#import "IBShareManager.h"
#import "IBAuthManager.h"
#import "IBActionSheet.h"
#import "MBProgressHUD+Ext.h"
#import "NSDictionary+Ext.h"
#import "NSArray+Ext.h"
#import "IBPopoverView.h"
#import "MBErrorCheck.h"
#import "MBLogger.h"
#import "IBHelper.h"
#import "MBUserManager.h"
#import "IBAtomFactory.h"
#import "MBLibraryCamera.h"
#import "IBMacros.h"
#import "UIMacros.h"
#import "MBGestureView.h"
#import "MBAlignmentLabel.h"
#import "Masonry.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIView *testView;
@property (nonatomic, strong) MBLibraryCamera *camera;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"主界面";

    self.config = [[IBNaviConfig alloc] initWithBarOptions:IBNaviBarOptionShow | IBNaviBarOptionColor tintColor:[UIColor orangeColor] backgroundColor:[UIColor redColor] backgroundImage:nil backgroundImgID:nil];

    

    
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)test {
    NSLog(@"123");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];    
    MBLog(@"%@", [IBAtomFactory sharedInstance].atomDict);
    MBLog(@"%@", [IBApp UUID]);
    return;

    IBMineController *mine = [[IBMineController alloc] init];
    mine.config = [[IBNaviConfig alloc] initWithBarOptions:IBNaviBarOptionShow|IBNaviBarOptionColor tintColor:[UIColor orangeColor] backgroundColor:[UIColor purpleColor] backgroundImage:nil backgroundImgID:nil];
    [self.navigationController pushViewController:mine animated:YES];
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
