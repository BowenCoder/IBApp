//
//  IBHTTPEngine.h
//  IBApplication
//
//  Created by Bowen on 2019/8/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBURLRequest.h"
#import "IBEncode.h"

NS_ASSUME_NONNULL_BEGIN

@interface IBHTTPEngine : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedInstance;

/**
 发送网络请求

 @param request 请求
 */
- (void)sendRequest:(IBURLRequest *)request;

/**
 取消网络请求

 @param request 请求
 */
- (void)cancelRequest:(IBURLRequest *)request;

/**
 取消所有网络请求
 */
- (void)cancelAllOperations;

/**
 *  是否打开网络状态转圈菊花:默认打开
 *
 *  @param open YES(打开), NO(关闭)
 */
- (void)openNetworkActivityIndicator:(BOOL)open;

/**
 * 验证证书
 *
 * @param name 证书名称
 * @param validatesDomainName 是否需要验证域名
 */
- (void)setSecurityPolicyWithCerName:(NSString *)name validatesDomainName:(BOOL)validatesDomainName;

@end

NS_ASSUME_NONNULL_END
