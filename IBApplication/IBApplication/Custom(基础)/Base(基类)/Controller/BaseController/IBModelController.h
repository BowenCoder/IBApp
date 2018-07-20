//
//  IBModelController.h
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBController.h"
#import "IBHTTPClient.h"
#import "IBNaviConfig.h"
#import "IBNaviController.h"
#import "IBTabBarController.h"

@interface IBModelController : IBController

@property (nonatomic, strong) IBNaviConfig *config;

/** 获取自定义导航控制器 */
@property (nonatomic, readonly, strong) IBNaviController *naviController;
/** 获取自定义标签控制器 */
@property (nonatomic, readonly, strong) IBTabBarController *tabController;

- (void)pageLoad:(NSString *)url params:(NSDictionary *)params success:(HTTPClientSuccess)success failure:(HTTPClientError)failure isGet:(BOOL)isGet;

@end
