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

    self.config = [[IBNaviConfig alloc] initWithBarOptions:IBNaviBarOptionShow | IBNaviBarOptionColor tintColor:[UIColor orangeColor] backgroundColor:[UIColor redColor] backgroundImage:nil backgroundImgID:nil];
    [self addRefreshHeader];
    [self addRefreshFooter];
    NSMutableArray *arr = @[].mutableCopy;
    [arr addObjectOrNil:[NSNull null]];

    NSLog(@"%@", NSStringFromCGRect(CGRectMakeFit(111, 333, 555, 777)));
    NSLog(@"demo %lf", ceil(2.1 * kScreenScale) / kScreenScale);
    
    NSString *str = @"https://service.bowen.com/time/config?lc=0000000000000003&cc=TG0001&cv=AURORA1.0.30_iPhone&proto=0&idfa=59F39E5E-88ED-410F-874D-84786CDCA15E&idfv=E74599B5-41E2-4A80-BD51-FC728B12A902&devi=bf39596600d61c1fb8c6c308a0893abf0402e78f&osversion=ios_12.200000&ua=iPhone10_1&imei=&imsi=&uid=100669";
    NSDictionary *dict = [IBHelper dictionaryWithURL:[NSURL URLWithString:str]];
    MBLog(@"bowen %@", dict);
    NSLogger(@"bowen %@", dict);
    NSString *base = @"https://service.bojoapp.com/time/getconfig?";
    MBLog(@"%@", [IBHelper fullURL:base params:dict]);
    
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)test {
    NSLog(@"123");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    MBLog(@"123");
    return;
    UIView *red = [[UIView alloc] init];
    red.backgroundColor = UIColor.redColor;
    red.frame = CGRectMake(100, 100, 200, 200);
    [self.popupManager presentContentView:red duration:0.25 springAnimated:YES];
    
    return;

    
//    [MBProgressHUD showCircleLoadingView:self.view];
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//    view.backgroundColor = [UIColor redColor];
//    self.popupManager = [IBPopupManager popupManagerWithMaskType:IBPopupMaskTypeBlackBlur];
//    self.popupManager.slideStyle = IBPopupSlideStyleShrinkInOut1;
//    self.popupManager.allowPan = YES;
//    self.popupManager.dismissOnMaskTouched = YES;
//    self.popupManager.dismissOppositeDirection = YES;
//    [self.popupManager presentContentView:view];
    
//    AXWebViewController *webVC = [[AXWebViewController alloc] initWithAddress:@"https://www.iqiyi.com"];
//    webVC.showsToolBar = YES;
//     webVC.showsNavigationCloseBarButtonItem = NO;
//    if (AX_WEB_VIEW_CONTROLLER_iOS9_0_AVAILABLE()) {
//        webVC.webView.allowsLinkPreview = YES;
//    }
//    [self.navigationController pushViewController:webVC animated:YES];


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
