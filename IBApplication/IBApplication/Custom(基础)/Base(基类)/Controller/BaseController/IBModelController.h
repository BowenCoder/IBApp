//
//  IBModelController.h
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBController.h"
#import "IBHTTPClient.h"
#import "IBNaviController.h"
#import "IBTabBarController.h"

@interface IBModelController : IBController

/** 获取自定义导航控制器 */
@property (nonatomic, readonly, strong) IBNaviController *naviController;
/** 获取自定义标签控制器 */
@property (nonatomic, readonly, strong) IBTabBarController *tabController;

/** 请求数据 */
- (void)requestData:(NSString *)url params:(NSDictionary *)params callback:(HTTPClientHandle)handle isGet:(BOOL)isGet;

/** 加载页面数据 */
- (void)pageLoad:(NSString *)url params:(NSDictionary *)params callback:(HTTPClientHandle)handle isGet:(BOOL)isGet;



@end
