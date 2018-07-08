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

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIView *testView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor lightGrayColor];
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0, 500, self.view.frame.size.width, 44)];
    tf.borderStyle = UITextBorderStyleLine;
//    tf.spellCheckingType = UITextSpellCheckingTypeNo;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:tf];
    self.openKeyListener = YES;
//    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, self.view.width - 100, 200)];
//    UIImage *img = [UIImage imageNamed:@"test"];
//    self.imageView.image = img;
//    self.imageView.backgroundColor = [UIColor lightGrayColor];
//    self.imageView.userInteractionEnabled = YES;
//    [self.view addSubview:self.imageView];
//    [MBProgressHUD showNoData:self.view reload:nil];
//    [self rightBarItemWithTitle:@"关注" titleColor:nil imageName:nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
//    IBMineController *mine = [[IBMineController alloc] init];
//    [self.navigationController pushViewController:mine animated:YES];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}





@end
