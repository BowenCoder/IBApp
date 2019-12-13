//
//  IBUploader.m
//  IBApplication
//
//  Created by Bowen on 2019/12/13.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBUploader.h"
#import "IBNetworkEngine.h"

@implementation IBUploader

+ (void)uploadImage:(UIImage *)image url:(NSString *)url completion:(IBHTTPCompletion)completion
{
    [self uploadImage:image url:url compressionQuality:0.5 progress:^(CGFloat progress) {
        
    } completion:completion];
}

+ (void)uploadImage:(UIImage *)image url:(NSString *)url compressionQuality:(CGFloat)quality progress:(void (^)(CGFloat progress))uploadProgress completion:(IBHTTPCompletion)completion
{
    NSData *imageData = UIImageJPEGRepresentation(image, quality);
    [self uploadData:imageData url:url progress:uploadProgress completion:completion];
}

+ (void)uploadData:(NSData *)data url:(NSString *)url progress:(void (^)(CGFloat progress))uploadProgress completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.method = IBHTTPPOST;
    
    request.uploadProgressHandler = ^(NSProgress *progress) {
        if (uploadProgress) {
            CGFloat currentProgress = progress.completedUnitCount/progress.totalUnitCount;
            uploadProgress(currentProgress);
        }
    };
    
    request.completionHandler = ^(IBURLResponse *response) {
        if (completion) {
            completion(response.code, response);
        }
    };
    
    [[IBNetworkEngine defaultEngine] sendUploadRequest:request data:data];
}

+ (void)uploadFile:(NSString *)path url:(NSString *)url progress:(void (^)(CGFloat progress))uploadProgress completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.method = IBHTTPPOST;
    
    request.uploadProgressHandler = ^(NSProgress *progress) {
        if (uploadProgress) {
            CGFloat currentProgress = progress.completedUnitCount/progress.totalUnitCount;
            uploadProgress(currentProgress);
        }
    };
    
    request.completionHandler = ^(IBURLResponse *response) {
        if (completion) {
            completion(response.code, response);
        }
    };
    
    [[IBNetworkEngine defaultEngine] sendUploadRequest:request path:path];
}

+ (void)uploadData:(NSData *)data fieldName:(NSString *)fieldName fileName:(NSString *)fileName mimeType:(NSString *)mimeType url:(NSString *)url progress:(void (^)(CGFloat progress))uploadProgress completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.method = IBHTTPPOST;
    
    request.uploadProgressHandler = ^(NSProgress *progress) {
        if (uploadProgress) {
            CGFloat currentProgress = progress.completedUnitCount/progress.totalUnitCount;
            uploadProgress(currentProgress);
        }
    };
    
    request.completionHandler = ^(IBURLResponse *response) {
        if (completion) {
            completion(response.code, response);
        }
    };
    
    [[IBNetworkEngine defaultEngine] sendUploadRequest:request constructingBody:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:fieldName fileName:fileName mimeType:mimeType];
    }];
}

+ (void)cancelRequestWithUrl:(NSString *)url
{
    [[IBNetworkEngine defaultEngine] cancelRequestWithUrl:url];
}

+ (void)cancelAllUploadTasks
{
    [[IBNetworkEngine defaultEngine] cancelAllUploadTasks];
}


@end
