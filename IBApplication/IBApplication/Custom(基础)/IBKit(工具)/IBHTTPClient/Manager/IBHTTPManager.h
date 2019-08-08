//
//  IBHTTPManager.h
//  IBApplication
//
//  Created by Bowen on 2019/6/17.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBHTTPManagerProtocol.h"
#import "IBRequest.h"
#import "IBResponse.h"
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface IBHTTPManager : NSObject<IBHTTPManagerProtocol>

+ (instancetype)sharedInstance;

/**
 *  GET 不支持缓存
 *
 *  @param url        url description
 *  @param params     params description
 *  @param completion completion description
 */
+ (void)GET:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletionBlock)completion;

/**
 *  GET 不支持缓存 请求不需要附加ATOM信息的
 *
 *  @param url        url description
 *  @param params     params description
 *  @param completion completion description
 */
+ (void)GETWithoutAtom:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletionBlock)completion;

/**
 *  GET请求  支持缓存和超时可配置
 *
 *  @param url             url description
 *  @param params          params description
 *  @param cacheType       cacheType description
 *  @param secs            secs description
 *  @param interval        interval description
 *  @param completion      completion description
 */
+ (void)GET:(NSString *)url params:(NSDictionary *)params cacheType:(IBHttpCacheType)cacheType cacheTime:(NSUInteger)secs timeout:(NSUInteger)interval completion:(IBHTTPCompletionBlock)completion;

/**
 *  GET请求 会重试三次 重试间隔至少为：5s
 *
 *  @param url             url description
 *  @param params          params description
 *  @param cacheType       cacheType description
 *  @param secs            secs description
 *  @param interval        interval description
 *  @param completion      completion description
 */
+ (void)GETRetry:(NSString *)url params:(NSDictionary *)params cacheType:(IBHttpCacheType)cacheType cacheTime:(NSUInteger)secs timeout:(NSUInteger)interval completion:(IBHTTPCompletionBlock)completion;

/**
 *  POST
 *
 *  @param url        url description
 *  @param params     params description
 *  @param body       body description
 *  @param completion completion description
 */
+ (void)POST:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body completion:(IBHTTPCompletionBlock)completion;

/**
 *  POST 请求不需要附加ATOM信息的
 *
 *  @param url        url description
 *  @param params     params description
 *  @param body       body description
 *  @param completion completion description
 */
+ (void)POSTWithoutAtom:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body completion:(IBHTTPCompletionBlock)completion;

/**
 *  POST
 *
 *  @param url             url description
 *  @param params          params description
 *  @param body            body description
 *  @param interval        interval description
 *  @param completion      completion description
 */
+ (void)POST:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body timeout:(NSUInteger)interval completion:(IBHTTPCompletionBlock)completion;

/**
 *  POST请求 会重试三次 重试间隔至少为：5s
 *
 *  @param url             url description
 *  @param params          params description
 *  @param body            body description
 *  @param interval        interval description
 *  @param completion      completion description
 */
+ (void)POSTRetry:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body timeout:(NSUInteger)interval completion:(IBHTTPCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
