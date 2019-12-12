//
//  IBHTTPClient.m
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBHTTPClient.h"
#import "IBServiceInfo.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation IBHTTPClient

+ (instancetype)shareInstance {
    
    static IBHTTPClient *shareInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[IBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@""]]; //需要配置
        shareInstance.requestSerializer.timeoutInterval = 10;
        shareInstance.requestSerializer = [AFJSONRequestSerializer serializer];
        shareInstance.responseSerializer = [AFJSONResponseSerializer serializer];
        NSSet *typesSet = [NSSet setWithObjects:@"application/json",@"text/html", @"text/json", @"text/javascript",@"application/x-javascript",@"text/plain",@"image/gif", nil];
        shareInstance.responseSerializer.acceptableContentTypes = typesSet;
        shareInstance.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    return shareInstance;
}

+ (void)GET:(NSString *)url
     params:(NSDictionary *)params
   callback:(HTTPClientHandle)handle {
    
    IBHTTPClient *client = [IBHTTPClient shareInstance];
    
    [client GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (handle) {
            handle(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (handle) {
            handle(nil, error);
        }
    }];
}

+ (void)POST:(NSString *)url
      params:(NSDictionary *)params
    callback:(HTTPClientHandle)handle {
    
    IBHTTPClient *client = [IBHTTPClient shareInstance];
    
    [client POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (handle) {
            handle(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (handle) {
            handle(nil, error);
        }
    }];
}

+ (void)POST:(NSString *)url
      params:(NSDictionary *)params
        data:(NSData *)fileData
   fieldName:(NSString *)fieldName
    fileName:(NSString *)fileName
    mimeType:(NSString *)mimeType
    callback:(HTTPClientHandle)handle {
    
    IBHTTPClient *client = [IBHTTPClient shareInstance];
    
    [client POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:fieldName fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (handle) {
            handle(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (handle) {
            handle(nil, error);
        }
    }];
    
}

+ (void)uploadFile:(NSString *)url
          fromFile:(NSURL *)path
          progress:(void(^)(NSProgress *progress))progress
          callback:(HTTPClientHandle)handle {
    
    NSURL *requestURL = [NSURL URLWithString:url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:path progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error && handle) {
            handle(nil, error);
            return;
        }
        if (responseObject && handle) {
            handle(responseObject, nil);
        }
    }];
    [uploadTask resume];
}

+ (void)uploadData:(NSString *)url
          fromData:(NSData *)data
          progress:(void(^)(NSProgress *progress))progress
          callback:(HTTPClientHandle)handle {
    
    NSURL *requestURL = [NSURL URLWithString:url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromData:data progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error && handle) {
            handle(nil, error);
            return;
        }
        if (responseObject && handle) {
            handle(responseObject, nil);
        }
    }];
    [uploadTask resume];
}

+ (void)downloadData:(NSString *)url
              params:(NSDictionary *)params
                save:(NSString *)path
            complete:(void (^)(NSData *data, NSError *error))complete
            progress:(void (^)(NSProgress *progress))progress {
    
    NSURL *requestURL = [NSURL URLWithString:url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progress(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        cachesPath = [cachesPath stringByAppendingString:@"afn_download"];
        NSString *fullPath = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path != nil ? path : fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        // filePath就是下载文件的位置，可以直接拿来使用
        NSData *data;
        if (!error) {
            data = [NSData dataWithContentsOfURL:filePath];
        }
        if (complete) complete(data, error);
        
    }];
    [downloadTask resume];
}

+ (void)cancelAllOperations {
    
    IBHTTPClient *client = [IBHTTPClient shareInstance];
    [client.operationQueue cancelAllOperations];
}

+ (void)openNetworkActivityIndicator:(BOOL)open {
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}

@end
