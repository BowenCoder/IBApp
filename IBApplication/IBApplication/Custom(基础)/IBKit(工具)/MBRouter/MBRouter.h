//
//  MBRouter.h
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBRouterProtocol.h"
#import "MBRouterRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBRouter : NSObject

+ (instancetype)defaultRouter;

/**
 *  每个模块注册自己的路由跳转处理，pName为空，例如第三方SDK、HTTP链接
 *
 *  @param scheme URL Scheme
 *  @param handler 处理跳转的类
 */
- (void)registerWithScheme:(NSString *)scheme handler:(Class<MBRouterProtocol>)handler;

/**
 *  每个模块注册自己的路由跳转处理，scheme 默认使用 kRouterDefaultScheme
 *
 *  @param pName 页面名称
 *  @param handler 处理跳转的类
 */
- (void)registerWithPName:(nullable NSString *)pName handler:(Class<MBRouterProtocol>)handler;

/**
 *  每个模块注册自己的路由跳转处理
 *
 *  @param scheme URL Scheme
 *  @param pName 页面名称
 *  @param handler 处理跳转的类
 */
- (void)registerWithScheme:(NSString *)scheme pName:(nullable NSString *)pName handler:(Class<MBRouterProtocol>)handler;

/**
 根据scheme移除路由

 @param scheme scheme 默认使用 kRouterDefaultScheme
 @param pName 页面名称 默认使用 kRouterDefaultScheme
 */
- (void)unregisterWithScheme:(NSString *)scheme pName:(nullable NSString *)pName;

/**
 *  打开指定的url （在主线程调用）
 *
 *  @return return 是否打开成功
 */
- (BOOL)open:(NSString *)url application:(nullable UIApplication *)application annotation:(nullable id)annotation target:(nullable __kindof UIViewController *)target;

/**
 *  打开指定的url （在主线程调用）
 *
 * @return return 是否打开成功
 */
- (BOOL)open:(NSString *)url target:(nullable __kindof UIViewController *)target responseHandler:(nullable MBRouterResultCallback)responseHandler;

/**
 *  打开指定的url （在主线程调用）
 *
 *  @param responseHandler 返回结果的处理器
 *  @return return 是否打开成功
 */
- (BOOL)open:(NSString *)url application:(nullable UIApplication *)application annotation:(nullable id)annotation target:(nullable __kindof UIViewController *)target responseHandler:(nullable MBRouterResultCallback)responseHandler;

/**
 *  获取处理跳转的类（也可用来去重） （在主线程调用）
 *
 *  @param scheme URL Scheme
 *  @param pName 页面名称
 *  @param enableFuzzyMatch 是否支持模糊匹配
 *  @return return 处理跳转的类
 */
- (Class<MBRouterProtocol>)handlerForScheme:(NSString *)scheme pName:(nullable NSString *)pName enableFuzzyMatch:(BOOL)enableFuzzyMatch;

@end

NS_ASSUME_NONNULL_END
