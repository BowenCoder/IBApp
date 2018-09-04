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
    
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)test {
    NSLog(@"123");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    IBShareObject *obj = [[IBShareObject alloc] init];
    obj.platformType = IBSharePlatformWechatTimeLine;
    obj.image = [UIImage imageNamed:@"test"];
    obj.previewImage = [UIImage imageNamed:@"bg"];
    obj.urlString = @"www.baidu.com";
//    obj.previewUrlString = @"www.inke.cn";
    obj.title = @"123456789";
    obj.text = @"qwert";
//    [[IBShareManager manager] shareImage:obj success:^(id response) {
//
//    } failure:^(NSError *error) {
//
//    }];
//    [[IBShareManager manager] shareLink:obj success:^(id response) {
//
//    } failure:^(NSError *error) {
//
//    }];
    
    IBActionItem *item = [IBActionItem itemWithType:IBActionTypeNormal image:[UIImage imageNamed:@"FSActionSheet_cancel"] title:@"你好" tintColor:[UIColor redColor] handler:^(IBActionItem *item, NSInteger selectedIndex) {
        NSLog(@"123");
    }];
    IBActionSheet *sheet = [[IBActionSheet alloc] initWithTitle:@"2018年7月3日，曾经为08年总冠军凯尔特人立下汗马功劳的拉简-朗多宣布以1年900万签约湖人，他的决定从某种程度上比勒布朗西游洛杉矶还要让人惊讶：这位绿军夺冠功臣、半年前还怒喷小托马斯配不上凯尔特人的老派球员，居然加入了一支曾在总决赛中相互纠缠怒目相对的队伍，更不要提两支球队自上世纪60年代延续至今的恩怨情仇，以及他个人和勒布朗之间的宿怨。" cancelItem:nil items:@[item, item, item, item, item, item, item, item, item, item, item, item]];
    [sheet show];

    
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
