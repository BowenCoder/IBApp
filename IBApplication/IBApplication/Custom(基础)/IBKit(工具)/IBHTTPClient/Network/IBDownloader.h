//
//  IBDownloader.h
//  IBApplication
//
//  Created by Bowen on 2019/12/13.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBURLRequest.h"

@interface IBDownloader : NSObject

/// 下载文件
/// @param url url
/// @param path 文件保存路径
/// @param completion 回调
+ (void)downloadFileWithUrl:(NSString *)url path:(NSString *)path completion:(IBHTTPCompletion)completion;

/// 下载文件
/// @param url url
/// @param path 文件保存路径
/// @param downloadProgress 进度
/// @param completion 回调
+ (void)downloadFileWithUrl:(NSString *)url path:(NSString *)path progress:(void (^)(CGFloat progress))downloadProgress completion:(IBHTTPCompletion)completion;

/**
 取消网络请求

 @param url 链接
 */
+ (void)cancelRequestWithUrl:(NSString *)url;

/**
取消所有下载请求
*/
+ (void)cancelAllDownloadTasks;


@end
