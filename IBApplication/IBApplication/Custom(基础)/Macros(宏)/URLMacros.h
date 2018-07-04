//
//  URLMacros.h
//  IBApplication
//
//  Created by Bowen on 2018/6/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#ifndef URLMacros_h
#define URLMacros_h

//内部版本号 每次发版递增
#define KVersionCode 1

/*
 将项目中所有的接口写在这里,方便统一管理,降低耦合
 
 这里通过宏定义来切换你当前的服务器类型,
 将你要切换的服务器类型宏后面置为真(即>0即可),其余为假(置为0)
 */
#define IB_DEVELOP_SEVER_OPEN    0
#define IB_TEST_SEVER_OPEN       1
#define IB_PRODUCT_SEVER_OPEN    0

#if IB_DEVELOP_SEVER_OPEN

/**开发服务器*/
#define IBBaseurl @"http://192.168.20.31:20000/shark-miai-service"

#elif IB_TEST_SEVER_OPEN

/**测试服务器*/
#define IBBaseurl @"http://192.168.20.31:20000/shark-miai-service"

#elif IB_PRODUCT_SEVER_OPEN

/**生产服务器*/
#define IBBaseurl @"http://192.168.20.31:20000/shark-miai-service"

#endif


#pragma mark - ——————— 详细接口地址 ————————

//测试接口
#define URL_Test @"/api/cast/home/start"


#pragma mark - ——————— 用户相关 ————————
//自动登录
#define URL_user_auto_login @"/api/autoLogin"
//登录
#define URL_user_login @"/api/login"
//用户详情
#define URL_user_info_detail @"/api/user/info/detail"
//修改头像
#define URL_user_info_change_photo @"/api/user/info/changephoto"
//注释
#define URL_user_info_change @"/api/user/info/change"

#endif /* URLMacros_h */
