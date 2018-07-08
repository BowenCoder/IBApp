//
//  IBHTTPClient.h
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

typedef void(^HTTPClientSuccess)(id JSON);
typedef void(^HTTPClientError)(NSError *error);

typedef NS_ENUM(NSInteger, HTTPClientNetworkStatus){
    HTTPClientNetworkUnknown       = -1,
    HTTPClientNetworkNotReachable  = 0,
    HTTPClientNetworkViaWWAN       = 1,
    HTTPClientNetworkViaWiFi       = 2
};

@interface IBHTTPClient : AFHTTPSessionManager

@property (nonatomic, assign) HTTPClientNetworkStatus networkStatus;

+ (instancetype)shareInstance;

/**
 GET请求
 
 @param url 请求路径
 @param view 发送方视图
 @param params 参数
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)GET:(NSString *)url
       send:(UIView *)view
     params:(NSDictionary *)params
    success:(HTTPClientSuccess)success
    failure:(HTTPClientError)failure;

/**
 POST请求

 @param url 请求路径
 @param view 发送方视图
 @param params 参数
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)POST:(NSString *)url
        send:(UIView *)view
      params:(NSDictionary *)params
     success:(HTTPClientSuccess)success
     failure:(HTTPClientError)failure;

/**
 *  向服务器上传文件
 *
 *  @param url       要上传的文件接口
 *  @param view      发送方视图
 *  @param params    上传的参数
 *  @param fileData  上传的文件\数据
 *  @param fieldName 服务对应的字段
 *  @param fileName  上传到时服务器的文件名
 *  @param mimeType  上传的文件类型
 *  @param success   成功执行，block的参数为服务器返回的内容
 *  @param failure   执行失败，block的参数为错误信息
 */
+ (void)POST:(NSString *)url
        send:(UIView *)view
      params:(NSDictionary *)params
        data:(NSData *)fileData
   fieldName:(NSString *)fieldName
    fileName:(NSString *)fileName
    mimeType:(NSString *)mimeType
     success:(HTTPClientSuccess)success
     failure:(HTTPClientError)failure;

/**
 *  NSURL上传文件
 *
 *  @param url       目标地址
 *  @param view      发送方视图
 *  @param path      文件源
 *  @param progress  实时进度回调
 *  @param success   成功执行，block的参数为服务器返回的内容
 *  @param failure   执行失败，block的参数为错误信息
 */
+ (void)uploadFile:(NSString *)url
              send:(UIView *)view
          fromFile:(NSURL *)path
          progress:(void(^)(NSProgress *progress))progress
           success:(HTTPClientSuccess)success
           failure:(HTTPClientError)failure;

/**
 *  NSURL上传数据
 *
 *  @param url       目标地址
 *  @param view      发送方视图
 *  @param data      文件源
 *  @param progress  实时进度回调
 *  @param success   成功执行，block的参数为服务器返回的内容
 *  @param failure   执行失败，block的参数为错误信息
 */
+ (void)uploadData:(NSString *)url
              send:(UIView *)view
          fromData:(NSData *)data
          progress:(void(^)(NSProgress *progress))progress
           success:(HTTPClientSuccess)success
           failure:(HTTPClientError)failure;

/**
 *  下载文件
 *
 *  @param url       下载地址
 *  @param view      发送方视图
 *  @param params    下载参数
 *  @param path      保存路径
 *  @param complete  下载成功返回文件：NSData
 *  @param progress  设置进度条的百分比：progressValue
 */
+ (void)downloadData:(NSString *)url
                send:(UIView *)view
              params:(NSDictionary *)params
                save:(NSString *)path
            complete:(void (^)(NSData *data, NSError *error))complete
            progress:(void (^)(NSProgress *progress))progress;

/**
 取消请求
 */
+ (void)cancelAllOperations;

/**
 *   监听网络状态的变化(全局开启一次就行)
 */
+ (void)checkingNetworkStatus:(void(^)(HTTPClientNetworkStatus status))callback;

@end
