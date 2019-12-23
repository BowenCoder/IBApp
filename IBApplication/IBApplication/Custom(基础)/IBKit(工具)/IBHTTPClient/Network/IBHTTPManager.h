//
//  IBHTTPManager.h
//  IBApplication
//
//  Created by Bowen on 2019/12/10.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBURLRequest.h"

@interface IBHTTPManager : NSObject

#pragma mark - GET

/**
 *  GET 不支持缓存
 *
 *  @param url        url description
 *  @param params     params description
 *  @param completion completion description
 */
+ (IBURLRequest *)GET:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletion)completion;

/**
 *  GET 不支持缓存 请求不需要附加ATOM信息的
 *
 *  @param url        url description
 *  @param params     params description
 *  @param completion completion description
 */
+ (IBURLRequest *)GETWithoutAtom:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletion)completion;

/**
 *  GET请求 会重试三次 重试间隔至少为：5s
 *
 *  @param url             url description
 *  @param params          params description
 *  @param completion      completion description
 */
+ (IBURLRequest *)GETRetry:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletion)completion;

/**
 *  GET请求  支持缓存和超时可配置
 *
 *  @param url             url description
 *  @param params          params description
 *  @param secs            secs description
 *  @param interval        interval description
 *  @param completion      completion description
 */
+ (IBURLRequest *)GET:(NSString *)url params:(NSDictionary *)params cacheTime:(NSUInteger)secs timeout:(NSUInteger)interval completion:(IBHTTPCompletion)completion;

#pragma mark - POST

/**
 *  POST
 *
 *  @param url        url description
 *  @param params     params description
 *  @param body       body description
 *  @param completion completion description
 */
+ (IBURLRequest *)POST:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body completion:(IBHTTPCompletion)completion;

/**
 *  POST 请求不需要附加ATOM信息的
 *
 *  @param url        url description
 *  @param params     params description
 *  @param body       body description
 *  @param completion completion description
 */
+ (IBURLRequest *)POSTWithoutAtom:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body completion:(IBHTTPCompletion)completion;

/**
 *  POST
 *
 *  @param url             url description
 *  @param params          params description
 *  @param body            body description
 *  @param interval        interval description
 *  @param completion      completion description
 */
+ (IBURLRequest *)POST:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body timeout:(NSUInteger)interval completion:(IBHTTPCompletion)completion;

/**
 *  POST请求 会重试三次 重试间隔至少为：5s
 *
 *  @param url             url description
 *  @param params          params description
 *  @param body            body description
 *  @param interval        interval description
 *  @param completion      completion description
 */
+ (IBURLRequest *)POSTRetry:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body timeout:(NSUInteger)interval completion:(IBHTTPCompletion)completion;

#pragma mark - 基本请求

/**
 * 基本请求
 *
 *  @param request      request description
 *  @param completion   completion description
 */
+ (void)sendRequest:(IBURLRequest *)request completion:(IBHTTPCompletion)completion;

#pragma mark - 其他操作

/**
 取消网络请求

 @param request 请求
 */
+ (void)cancelRequest:(IBURLRequest *)request;

/**
 取消请求
 */
+ (void)cancelAllTasks;

/**
 * 移除所有缓存
 */
+ (void)removeHttpCaches;

/**
 *  是否打开网络状态转圈菊花:默认打开
 *
 *  @param open YES(打开), NO(关闭)
 */
+ (void)openNetworkActivityIndicator:(BOOL)open;

/**
 * 验证证书
 *
 * @param name 证书名称
 * @param validatesDomainName 是否需要验证域名
 */
+ (void)setSecurityPolicyWithCerName:(NSString *)name validatesDomainName:(BOOL)validatesDomainName;


@end
