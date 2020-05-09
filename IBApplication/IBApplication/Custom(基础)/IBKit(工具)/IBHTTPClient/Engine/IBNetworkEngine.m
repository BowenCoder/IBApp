//
//  IBNetworkEngine.m
//  IBApplication
//
//  Created by Bowen on 2019/8/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBNetworkEngine.h"
#import "MBLogger.h"
#import "IBNetworkStatus.h"
#import "AFNetworkActivityIndicatorManager.h"

#define SemaphoreEngineLock dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
#define SemaphoreEngineUnlock dispatch_semaphore_signal(self.semaphore)

@interface IBNetworkEngine ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *sessionTasks;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation IBNetworkEngine

+ (instancetype)defaultEngine
{
    static IBNetworkEngine *engine;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[self alloc] init];
    });
    return engine;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.semaphore = dispatch_semaphore_create(1);
    self.sessionTasks = [NSMutableDictionary dictionary];
    self.manager = [AFHTTPSessionManager manager];
    self.manager.operationQueue.maxConcurrentOperationCount = 1;
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
}

- (void)sendHTTPRequest:(IBURLRequest *)request
{
    NSString *requestKey = [request requestKey];
    BOOL isError = [self handleRequest:request key:requestKey];
    if (isError) return;
    
    MBLogD(@"%@", request);
    
    NSURLSessionDataTask *dataTask = [self dataTaskWithRequest:request uploadProgress:^(NSProgress *uploadProgress){
        if (request.uploadProgressHandler) {
            request.uploadProgressHandler(uploadProgress);
        }
    } downloadProgress:^(NSProgress *downloadProgress) {
        if (request.downloadProgressHandler) {
            request.downloadProgressHandler(downloadProgress);
        }
    } success:^(NSURLSessionDataTask *dataTask, id resp) {
        [self removeSessionTaskForKey:requestKey];
        [self requestCompletion:request task:dataTask resp:resp error:nil];
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [self removeSessionTaskForKey:requestKey];
        [self requestCompletion:request task:dataTask resp:nil error:error];
    }];
    
    [self setSesssionTask:dataTask forKey:requestKey];
    
    [dataTask resume];
}

- (void)sendUploadRequest:(IBURLRequest *)request path:(NSString *)path
{
    NSString *requestKey = [request requestKey];
    BOOL isError = [self handleRequest:request key:requestKey];
    if (isError) return;
    
    MBLogD(@"%@", request);
    
    NSURLSessionUploadTask *uploadTask = [self uploadFileWithRequest:request filePath:path uploadProgress:^(NSProgress *uploadProgress) {
        if (request.uploadProgressHandler) {
            request.uploadProgressHandler(uploadProgress);
        }
    } completion:^(NSURLSessionUploadTask *task, id responseObject, NSError *error) {
        [self removeSessionTaskForKey:requestKey];
        [self requestCompletion:request task:task resp:responseObject error:error];
    }];
    
    [self setSesssionTask:uploadTask forKey:requestKey];
     
    [uploadTask resume];
}


- (void)sendUploadRequest:(IBURLRequest *)request data:(NSData *)data
{
    NSString *requestKey = [request requestKey];
    BOOL isError = [self handleRequest:request key:requestKey];
    if (isError) return;
    
    MBLogD(@"%@", request);
    
    NSURLSessionUploadTask *uploadTask = [self uploadDataWithRequest:request uploadData:data uploadProgress:^(NSProgress *uploadProgress) {
        if (request.uploadProgressHandler) {
            request.uploadProgressHandler(uploadProgress);
        }
    } completion:^(NSURLSessionUploadTask *task, id responseObject, NSError *error) {
        [self removeSessionTaskForKey:requestKey];
        [self requestCompletion:request task:task resp:responseObject error:error];
    }];
    
    [self setSesssionTask:uploadTask forKey:requestKey];
     
    [uploadTask resume];
}

- (void)sendUploadRequest:(IBURLRequest *)request constructingBody:(void (^)(id <AFMultipartFormData> formData))block;
{
    NSString *requestKey = [request requestKey];
    BOOL isError = [self handleRequest:request key:requestKey];
    if (isError) return;
    
    MBLogD(@"%@", request);
    
    NSString *url = [request sendUrl];
    NSDictionary *body = request.body;
    
    NSURLSessionDataTask *dataTask = [self.manager POST:url parameters:body constructingBodyWithBlock:block progress:^(NSProgress *uploadProgress) {
        if (request.uploadProgressHandler) {
            request.uploadProgressHandler(uploadProgress);
        }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self removeSessionTaskForKey:requestKey];
        [self requestCompletion:request task:task resp:responseObject error:nil];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self removeSessionTaskForKey:requestKey];
        [self requestCompletion:request task:task resp:nil error:error];
    }];
    
    [self setSesssionTask:dataTask forKey:requestKey];
    
    [dataTask resume];
}

- (void)sendDownloadRequest:(IBURLRequest *)request path:(NSString *)path
{
    NSString *requestKey = [request requestKey];
    BOOL isError = [self handleRequest:request key:requestKey];
    if (isError) return;
    
    MBLogD(@"%@", request);
    
    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequest:request filePath:path downloadProgress:^(NSProgress *progress) {
        if (request.downloadProgressHandler) {
            request.downloadProgressHandler(progress);
        }
    } completion:^(NSURLSessionDownloadTask *downloadTask, NSString *filePath, NSError *error) {
        [self removeSessionTaskForKey:requestKey];
        [self downloadCompletion:request task:downloadTask path:filePath error:error];
    }];
    
    [self setSesssionTask:downloadTask forKey:requestKey];
    
    [downloadTask resume];
}

- (void)cancelRequest:(IBURLRequest *)request
{
    NSString *requestKey = [request requestKey];
    NSURLSessionDataTask *dataTask = [self sessionTaskForKey:requestKey];
    [dataTask cancel];
    [self removeSessionTaskForKey:requestKey];
}

- (void)cancelAllTasks
{
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
}

- (void)cancelAllUploadTasks
{
    [self.manager.uploadTasks makeObjectsPerformSelector:@selector(cancel)];
}

- (void)cancelAllDownloadTasks
{
    [self.manager.downloadTasks makeObjectsPerformSelector:@selector(cancel)];
}

- (void)openNetworkActivityIndicator:(BOOL)open
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}

- (void)setSecurityPolicyWithCerName:(NSString *)name validatesDomainName:(BOOL)validatesDomainName
{
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:name ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = validatesDomainName;
    NSSet<NSData*> * set = [[NSSet alloc] initWithObjects:certData, nil];
    securityPolicy.pinnedCertificates = set;
    
    [self.manager setSecurityPolicy:securityPolicy];
}

#pragma mark - 私有

- (AFHTTPRequestSerializer *)requestSerializerWithRequest:(IBURLRequest *)request
{
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    requestSerializer.timeoutInterval = [request timeoutInterval];
    requestSerializer.allowsCellularAccess = [request allowsCellularAccess];
    
    NSArray *authFields = request.authHeaderFields;
    if (kIsArray(authFields)) {
        [requestSerializer setAuthorizationHeaderFieldWithUsername:authFields.firstObject password:authFields.lastObject];
    }
    
    NSDictionary *headerFields = request.headerFields;
    if (kIsDictionary(headerFields)) {
        for (NSString *headerField in headerFields.allKeys) {
            NSString *value = headerFields[headerField];
            [requestSerializer setValue:value forHTTPHeaderField:headerField];
        }
    }
    return requestSerializer;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(IBURLRequest *)sendRequest
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                      success:(void (^)(NSURLSessionDataTask *, id))success
                                      failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSString *url = [sendRequest sendUrl];
    NSString *method = [self methodStringWithType:sendRequest.method];
    NSDictionary *body = sendRequest.body;
    NSError *requestError = nil;
    AFHTTPRequestSerializer *serializer = [self requestSerializerWithRequest:sendRequest];
    
    NSMutableURLRequest *request = [serializer requestWithMethod:method URLString:url parameters:body error:&requestError];
    if (requestError) {
        if (failure) {
            failure(nil, requestError);
        }
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.manager dataTaskWithRequest:request
                                  uploadProgress:uploadProgress
                                downloadProgress:downloadProgress
                               completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                                   if (error) {
                                       if (failure) {
                                           failure(dataTask, error);
                                       }
                                   } else {
                                       if (success) {
                                           success(dataTask, responseObject);
                                       }
                                   }
                               }];
    
    return dataTask;
}

- (NSURLSessionUploadTask *)uploadFileWithRequest:(IBURLRequest *)sendRequest
                                         filePath:(NSString *)filePath
                                   uploadProgress:(void (^)(NSProgress *uploadProgress))uploadProgress
                                       completion:(void (^)(NSURLSessionUploadTask *task, id responseObject, NSError *error))completion
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL = [NSURL URLWithString:[sendRequest sendUrl]];
    request.HTTPMethod = [self methodStringWithType:sendRequest.method];
    
    NSURL *fileUrl = [NSURL URLWithString:filePath];
    
    __block NSURLSessionUploadTask *uploadTask = nil;

    uploadTask = [self.manager uploadTaskWithRequest:request fromFile:fileUrl progress:^(NSProgress * progress) {
        uploadProgress(progress);
    } completionHandler:^(NSURLResponse *response, id  responseObject, NSError *error) {
        completion(uploadTask, responseObject, error);
    }];
    
    return uploadTask;
}

- (NSURLSessionUploadTask *)uploadDataWithRequest:(IBURLRequest *)sendRequest
                                       uploadData:(NSData *)data
                                   uploadProgress:(void (^)(NSProgress *uploadProgress))uploadProgress
                                       completion:(void (^)(NSURLSessionUploadTask *task, id responseObject, NSError *error))completion
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL = [NSURL URLWithString:[sendRequest sendUrl]];
    request.HTTPMethod = [self methodStringWithType:sendRequest.method];
    
    __block NSURLSessionUploadTask *uploadTask = nil;

    uploadTask = [self.manager uploadTaskWithRequest:request fromData:data progress:^(NSProgress * progress) {
        uploadProgress(progress);
    } completionHandler:^(NSURLResponse *response, id  responseObject, NSError *error) {
        completion(uploadTask, responseObject, error);
    }];
    
    return uploadTask;
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(IBURLRequest *)sendRequest
                                             filePath:(NSString *)filePath
                                     downloadProgress:(void (^)(NSProgress *progress))downloadProgress
                                           completion:(void (^)(NSURLSessionDownloadTask *, NSString *, NSError *))completion
{
    NSURL *url = [NSURL URLWithString:[sendRequest sendUrl]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    __block NSURLSessionDownloadTask *downloadTask = nil;
    downloadTask = [self.manager downloadTaskWithRequest:request progress:^(NSProgress *progress) {
        downloadProgress(progress);
    } destination:^NSURL * _Nonnull(NSURL *targetPath, NSURLResponse *response) {
        NSString *fullPath;
        if (filePath) {
            fullPath = [filePath stringByAppendingPathComponent:response.suggestedFilename];
        } else {
            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            cachesPath = [cachesPath stringByAppendingString:@"AFNDownload"];
            fullPath = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        }
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        completion(downloadTask, filePath.absoluteString, error);
    }];
    
    return downloadTask;
}

// 容错处理
- (BOOL)handleRequest:(IBURLRequest *)request key:(NSString *)requestKey
{
    BOOL result = NO;
    NSString *message;
    IBURLErrorCode code = IBURLErrorUnknown;
    
    NSURLSessionDataTask *oldTask = [self sessionTaskForKey:requestKey];
    
    if (oldTask) {
        result = YES; code = IBURLErrorDouble; message = @"repeated network requests";
    }
    
    if (kIsEmptyString(request.url)) {
        result = YES; code = IBURLErrorAddress; message = @"url is nil";
    }
    
    if (request.method == IBHTTPNone) {
        result = YES; code = IBURLErrorMethod; message = @"method is nil";
    }
    
    if ([IBNetworkStatus shareInstance].currentNetworkStatus == IBNetworkStatusNotReachable) {
        result = YES; code = IBURLErrorBadNet; message = @"network is currently unavailable";
    }
    
    if (result) {
        MBLogE(@"#network# request failed %@", message);
        NSError *error = [NSError errorWithDomain:message code:code userInfo:nil];
        [self requestCompletion:request task:nil resp:nil error:error];
    }
    
    return result;
}

- (void)requestCompletion:(IBURLRequest *)request task:(NSURLSessionTask *)task resp:(NSData *)data error:(NSError *)error
{
    if (!request.completionHandler) {
        [request clearHandler];
        return;
    }
    
    IBURLResponse *response = [[IBURLResponse alloc] init];
    response.task = task;
    
    if (error) {
        response.code = error.code;
        response.message = error.localizedDescription;
    } else {
        response.data = data;
        [response parseResponse];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        request.completionHandler(response);
        [request clearHandler];
    });
}

- (void)downloadCompletion:(IBURLRequest *)request task:(NSURLSessionTask *)task path:(NSString *)path error:(NSError *)error
{
    if (!request.completionHandler) {
        [request clearHandler];
        return;
    }
    
    IBURLResponse *response = [[IBURLResponse alloc] init];
    response.task = task;
    
    if (error) {
        response.code = error.code;
        response.message = error.localizedDescription;
    } else {
        response.code = IBURLErrorSuccess;
        response.message = @"下载成功";
        response.dict = @{@"path": path};
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        request.completionHandler(response);
        [request clearHandler];
    });
}

- (NSURLSessionDataTask *)sessionTaskForKey:(NSString *)key
{
    if (kIsEmptyString(key)) {
        return nil;
    }
    SemaphoreEngineLock;
    NSURLSessionDataTask *dataTask = [self.sessionTasks objectForKey:key];
    SemaphoreEngineUnlock;
    return dataTask;
}

- (void)removeSessionTaskForKey:(NSString *)key
{
    if (kIsEmptyString(key)) {
        return;
    }
    SemaphoreEngineLock;
    [self.sessionTasks removeObjectForKey:key];
    SemaphoreEngineUnlock;
}

- (void)setSesssionTask:(NSURLSessionTask *)task forKey:(NSString *)key
{
    if (kIsEmptyObject(task) || kIsEmptyString(key)) {
        return;
    }
    SemaphoreEngineLock;
    [self.sessionTasks setObject:task forKey:key];
    SemaphoreEngineUnlock;
}

- (NSString *)methodStringWithType:(IBHTTPMethod)method
{
    NSString *methodString;
    switch (method) {
        case IBHTTPGET: methodString = @"GET"; break;
        case IBHTTPPOST: methodString = @"POST"; break;
        case IBHTTPPUT: methodString = @"PUT"; break;
        case IBHTTPHEAD: methodString = @"HEAD"; break;
        case IBHTTPPATCH: methodString = @"PATCH"; break;
        case IBHTTPDELETE: methodString = @"DELETE"; break;
        default: methodString = @"GET"; break;
    }
    return methodString;
}

@end

/*
 1、AFSSLPinningMode
 AFSSLPinningModePublicKey: 只认证公钥那一段
 AFSSLPinningModeCertificate: 使用证书验证模式，是证书所有字段都一样才通过认证，更安全。但是单向认证不能防止“中间人攻击”
 
 2、allowInvalidCertificates: 是否允许无效证书（也就是自建的证书），默认为NO，如果是需要验证自建证书，需要设置为YES
 
 3、validatesDomainName 是否需要验证域名，默认为YES
 假如证书的域名与你请求的域名不一致，需把该项设置为NO；
 如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
 设置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。
 因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；
 当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
 如置为NO，建议自己添加对应域名的校验逻辑。
 */
