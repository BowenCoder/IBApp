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

- (void)pageLoad:(NSString *)url params:(NSDictionary *)params callback:(HTTPClientHandle)handle isGet:(BOOL)isGet {
    
    [MBProgressHUD showTriangleLoadingView:self.view];
    [self requestData:url params:params callback:^(id JSON, NSError *error) {
        [MBProgressHUD hideTriangleLoadingView:self.view];
        if (error && handle) {
            handle(nil, error);
            [MBProgressHUD showNoData:self.view reload:^{
                [self pageLoad:url params:params callback:handle isGet:isGet];
            }];
        }
        if (JSON && handle) {
            handle(JSON, nil);
        }
    } isGet:isGet];

}

- (void)requestData:(NSString *)url params:(NSDictionary *)params callback:(HTTPClientHandle)handle isGet:(BOOL)isGet {
    if (isGet) {
        [IBHTTPClient GET:url params:params callback:^(id JSON, NSError *error) {
            if (error && handle) {
                handle(nil, error);
            }
            if (JSON && handle) {
                handle(JSON, nil);
            }
        }];
    } else {
        [IBHTTPClient POST:url params:params callback:^(id JSON, NSError *error) {
            if (error && handle) {
                handle(nil, error);
            }
            if (JSON && handle) {
                handle(JSON, nil);
            }
        }];
    }
}



#pragma mark - 私有方法


#pragma mark - 代理事件


#pragma mark - 合成存取

- (IBNaviController *)naviController {
    if (self.navigationController && [self.navigationController isKindOfClass:[IBNaviController class]]) {
        return (IBNaviController *)self.navigationController;
    }
    return nil;
}

- (IBTabBarController *)tabController {
    if (self.tabBarController && [self.tabBarController isKindOfClass:[IBTabBarController class]]) {
        return (IBTabBarController *)self.tabController;
    }
    return nil;
}


@end
