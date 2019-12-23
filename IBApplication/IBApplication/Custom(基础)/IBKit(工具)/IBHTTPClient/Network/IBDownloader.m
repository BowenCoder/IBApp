//
//  IBDownloader.m
//  IBApplication
//
//  Created by Bowen on 2019/12/13.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBDownloader.h"
#import "IBNetworkEngine.h"

@implementation IBDownloader

+ (IBURLRequest *)downloadFileWithUrl:(NSString *)url path:(NSString *)path completion:(IBHTTPCompletion)completion
{
    return [self downloadFileWithUrl:url path:path progress:^(CGFloat progress) {
        
    } completion:completion];
}

+ (IBURLRequest *)downloadFileWithUrl:(NSString *)url path:(NSString *)path progress:(void (^)(CGFloat progress))downloadProgress completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.method = IBHTTPGET;
    
    request.downloadProgressHandler = ^(NSProgress *progress) {
        if (downloadProgress) {
            CGFloat currentProgress = progress.completedUnitCount/progress.totalUnitCount;
            downloadProgress(currentProgress);
        }
    };
    
    request.completionHandler = ^(IBURLResponse *response) {
        if (completion) {
            completion(response.code, response);
        }
    };
    
    [[IBNetworkEngine defaultEngine] sendDownloadRequest:request path:path];
    
    return request;
}

+ (void)cancelRequest:(IBURLRequest *)request
{
    [[IBNetworkEngine defaultEngine] cancelRequest:request];
}

+ (void)cancelAllDownloadTasks
{
    [[IBNetworkEngine defaultEngine] cancelAllDownloadTasks];
}

@end
