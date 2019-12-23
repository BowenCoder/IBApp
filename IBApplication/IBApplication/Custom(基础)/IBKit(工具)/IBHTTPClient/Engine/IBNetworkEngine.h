//
//  IBNetworkEngine.h
//  IBApplication
//
//  Created by Bowen on 2019/8/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "IBURLRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface IBNetworkEngine : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)defaultEngine;

/**
 HTTP网络请求
 
 @param request 请求
 */
- (void)sendHTTPRequest:(IBURLRequest *)request;

/**
 上传文件网络请求
 
 @param request 请求
 @param path 上传文件路径
 */
- (void)sendUploadRequest:(IBURLRequest *)request path:(NSString *)path;

/**
 上传二进制数据网络请求
 
 @param request 请求
 @param data 上传数据
 */
- (void)sendUploadRequest:(IBURLRequest *)request data:(NSData *)data;

/**
 上传二进制数据网络请求
 @param request 请求
 @param block 回调拼接数据
 */
- (void)sendUploadRequest:(IBURLRequest *)request constructingBody:(void (^)(id<AFMultipartFormData> formData))block;

/**
 下载网络请求
 
 @param request 请求
 @param path 下载路径
 */
- (void)sendDownloadRequest:(IBURLRequest *)request path:(NSString *)path;

/**
 取消网络请求
 
 @param request 请求
 */
- (void)cancelRequest:(IBURLRequest *)request;

/**
 取消所有网络请求
 */
- (void)cancelAllTasks;

/**
 取消所有上传请求
 */
- (void)cancelAllUploadTasks;

/**
 取消所有下载请求
 */
- (void)cancelAllDownloadTasks;

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
