//
//  NSHTTPClient.m
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSHTTPClient.h"

@implementation NSHTTPClient

+ (instancetype)shareInstance {
    
    static NSHTTPClient *shareInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[NSHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:IBBaseurl]]; //需要配置
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
       send:(UIView *)view
     params:(NSDictionary *)params
    success:(NSHTTPClientSuccess)success
    failure:(NSHTTPClientError)failure {
    NSHTTPClient *client = [NSHTTPClient shareInstance];
    
    [client GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)POST:(NSString *)url
        send:(UIView *)view
      params:(NSDictionary *)params
     success:(NSHTTPClientSuccess)success
     failure:(NSHTTPClientError)failure {
    
    NSHTTPClient *client = [NSHTTPClient shareInstance];
    
    [client POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)POST:(NSString *)url
        send:(UIView *)view
      params:(NSDictionary *)params
        data:(NSData *)fileData
   fieldName:(NSString *)fieldName
    fileName:(NSString *)fileName
    mimeType:(NSString *)mimeType
     success:(NSHTTPClientSuccess)success
     failure:(NSHTTPClientError)failure {
    
    NSHTTPClient *client = [NSHTTPClient shareInstance];
    
    [client POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:fieldName fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

+ (void)uploadFile:(NSString *)url
              send:(UIView *)view
          fromFile:(NSURL *)path
          progress:(void(^)(NSProgress *progress))progress
           success:(NSHTTPClientSuccess)success
           failure:(NSHTTPClientError)failure {
    
    NSURL *requestURL = [NSURL URLWithString:url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:path progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error && failure) {
            failure(error);
            return;
        }
        if (responseObject && success) {
            success(responseObject);
        }
    }];
    [uploadTask resume];
}

+ (void)uploadData:(NSString *)url
              send:(UIView *)view
          fromData:(NSData *)data
          progress:(void(^)(NSProgress *progress))progress
           success:(NSHTTPClientSuccess)success
           failure:(NSHTTPClientError)failure {
    
    NSURL *requestURL = [NSURL URLWithString:url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromData:data progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error && failure) {
            failure(error);
            return;
        }
        if (responseObject && success) {
            success(responseObject);
        }
    }];
    [uploadTask resume];
}

+ (void)downloadData:(NSString *)url
                send:(UIView *)view
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

+ (void)checkingNetworkStatus:(void(^)(NSHTTPClientNetworkStatus status))callback {
    
    NSHTTPClient *client = [NSHTTPClient shareInstance];
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusUnknown) {
            client.networkStatus = NSHTTPClientNetworkUnknown;
            if (callback) callback(NSHTTPClientNetworkUnknown);
            
        }else if (status == AFNetworkReachabilityStatusNotReachable){
            client.networkStatus = NSHTTPClientNetworkNotReachable;
            if (callback) callback(NSHTTPClientNetworkNotReachable);
            
        }else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            client.networkStatus = NSHTTPClientNetworkViaWWAN;
            if (callback) callback(NSHTTPClientNetworkViaWWAN);
            
        }else if (status == AFNetworkReachabilityStatusReachableViaWiFi){
            client.networkStatus = NSHTTPClientNetworkViaWiFi;
            if (callback) callback(NSHTTPClientNetworkViaWiFi);
            
        }
    }];
}

+ (void)cancelAllOperations {
    
    NSHTTPClient *client = [NSHTTPClient shareInstance];
    [client.operationQueue cancelAllOperations];
}

@end
