//
//  IBUploader.h
//  IBApplication
//
//  Created by Bowen on 2019/12/13.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBURLRequest.h"

@interface IBUploader : NSObject

/// 上传图片
/// @param image 图片
/// @param url url
/// @param completion 回调
+ (void)uploadImage:(UIImage *)image url:(NSString *)url completion:(IBHTTPCompletion)completion;

/// 上传图片
/// @param image 图片
/// @param url url
/// @param quality 压缩质量
/// @param uploadProgress 进度
/// @param completion 回调
+ (void)uploadImage:(UIImage *)image url:(NSString *)url compressionQuality:(CGFloat)quality progress:(void (^)(CGFloat progress))uploadProgress completion:(IBHTTPCompletion)completion;

/// 上传二进制数据
/// @param data 数据
/// @param url url
/// @param uploadProgress 进度
/// @param completion 回调
+ (void)uploadData:(NSData *)data url:(NSString *)url progress:(void (^)(CGFloat progress))uploadProgress completion:(IBHTTPCompletion)completion;

/// 上传文件
/// @param path 路径
/// @param url url
/// @param uploadProgress 进度
/// @param completion 回调
+ (void)uploadFile:(NSString *)path url:(NSString *)url progress:(void (^)(CGFloat progress))uploadProgress completion:(IBHTTPCompletion)completion;

/// 上传二进制数据
/// @param data 数据
/// @param fieldName 字段
/// @param fileName 文件名
/// @param mimeType 文件类型
/// @param url url
/// @param uploadProgress 进度
/// @param completion 回调
+ (void)uploadData:(NSData *)data fieldName:(NSString *)fieldName fileName:(NSString *)fileName mimeType:(NSString *)mimeType url:(NSString *)url progress:(void (^)(CGFloat progress))uploadProgress completion:(IBHTTPCompletion)completion;

/**
 取消网络请求

 @param url 链接
 */
+ (void)cancelRequestWithUrl:(NSString *)url;

/**
取消所有上传请求
*/
+ (void)cancelAllUploadTasks;


@end
