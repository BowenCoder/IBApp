//
//  IBHTTPClient.h
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

typedef void(^HTTPClientHandle)(id JSON, NSError *error);

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
 @param params 参数
 @param handle 网络回调
 */
+ (void)GET:(NSString *)url
     params:(NSDictionary *)params
   callback:(HTTPClientHandle)handle;

/**
 POST请求

 @param url 请求路径
 @param params 参数
 @param handle 网络回调
 */
+ (void)POST:(NSString *)url
      params:(NSDictionary *)params
    callback:(HTTPClientHandle)handle;

/**
 向服务器上传文件

 @param url 要上传的文件接口
 @param params 上传的参数
 @param fileData 上传的文件\数据
 @param fieldName 服务对应的字段
 @param fileName 上传到时服务器的文件名
 @param mimeType 上传的文件类型
 @param handle 网络回调
 */
+ (void)POST:(NSString *)url
      params:(NSDictionary *)params
        data:(NSData *)fileData
   fieldName:(NSString *)fieldName
    fileName:(NSString *)fileName
    mimeType:(NSString *)mimeType
    callback:(HTTPClientHandle)handle;

/**
 NSURL上传文件
 
 @param url       目标地址
 @param path      文件源
 @param progress  实时进度回调
 @param handle    网络回调
 */
+ (void)uploadFile:(NSString *)url
          fromFile:(NSURL *)path
          progress:(void(^)(NSProgress *progress))progress
          callback:(HTTPClientHandle)handle;

/**
 NSURL上传数据
 
 @param url       目标地址
 @param data      文件源
 @param progress  实时进度回调
 @param handle    网络回调
 */
+ (void)uploadData:(NSString *)url
          fromData:(NSData *)data
          progress:(void(^)(NSProgress *progress))progress
          callback:(HTTPClientHandle)handle;

/**
 下载文件
 
 @param url       下载地址
 @param params    下载参数
 @param path      保存路径
 @param complete  下载成功返回文件：NSData
 @param progress  设置进度条的百分比：progressValue
 */
+ (void)downloadData:(NSString *)url
              params:(NSDictionary *)params
                save:(NSString *)path
            complete:(void (^)(NSData *data, NSError *error))complete
            progress:(void (^)(NSProgress *progress))progress;

/**
 取消请求
 */
+ (void)cancelAllOperations;

/**
 监听网络状态的变化(全局开启一次就行)
 */
+ (void)checkingNetworkStatus:(void(^)(HTTPClientNetworkStatus status))callback;

@end
