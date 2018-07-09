//
//  IBModelController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBModelController.h"
#import "MBProgressHUD+Ext.h"

@interface IBModelController ()


@end

@implementation IBModelController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    
}


#pragma mark - 重写方法

#pragma mark - 公开方法

- (void)pageLoad:(NSString *)url params:(NSDictionary *)params success:(HTTPClientSuccess)success failure:(HTTPClientError)failure isGet:(BOOL)isGet {
    
    [MBProgressHUD showTriangleLoadingView:self.view];
    if (isGet) {
        [IBHTTPClient GET:url send:nil params:params success:^(id JSON) {
            if (success) {
                success(JSON);
            }
            [MBProgressHUD hideTriangleLoadingView:self.view];
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
            [MBProgressHUD hideTriangleLoadingView:self.view];
            [MBProgressHUD showNoData:self.view reload:^{
                [self pageLoad:url params:params success:success failure:failure isGet:YES];
            }];
        }];
    } else {
        [IBHTTPClient POST:url send:nil params:params success:^(id JSON) {
            if (success) {
                success(JSON);
            }
            [MBProgressHUD hideTriangleLoadingView:self.view];
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
            [MBProgressHUD hideTriangleLoadingView:self.view];
            [MBProgressHUD showNoData:self.view reload:^{
                [self pageLoad:url params:params success:success failure:failure isGet:YES];
            }];
        }];
    }
}



#pragma mark - 私有方法


#pragma mark - 代理事件


#pragma mark - 合成存取




@end
