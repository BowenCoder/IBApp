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

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIView *testView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, self.view.width - 100, 200)];
    UIImage *img = [UIImage imageNamed:@"test"];
    self.imageView.image = img;
    self.imageView.backgroundColor = [UIColor lightGrayColor];
    self.imageView.userInteractionEnabled = YES;
    [self.view addSubview:self.imageView];

    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    IBMineController *mine = [[IBMineController alloc] init];
    [self.navigationController pushViewController:mine animated:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
