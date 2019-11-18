//
//  IBHTTPEngine.m
//  IBApplication
//
//  Created by Bowen on 2019/8/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBHTTPEngine.h"
#import "MBLogger.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

#define EngineLock dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
#define EngineUnlock dispatch_semaphore_signal(self.semaphore)

@interface IBHTTPEngine ()

@property (nonatomic, strong) dispatch_queue_t httpQueue;
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *sessionTasks;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation IBHTTPEngine

+ (instancetype)sharedInstance
{
    static IBHTTPEngine *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance setup];
    });
    return instance;
}

- (void)setup
{
    self.semaphore = dispatch_semaphore_create(1);
    self.sessionTasks = [NSMutableDictionary dictionary];
    self.manager = [AFHTTPSessionManager manager];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
}

- (void)sendRequest:(IBURLRequest *)request
{
    NSString *requestKey = [IBEncode md5WithString:request.url];
    BOOL isError = [self tolerateRequest:request key:requestKey];
    if (isError) return;
        
    NSString      *url = request.sendUrl;
    NSString   *method = [self methodStringWithType:request.method];
    NSDictionary *body = request.body;
    
    MBLogD(@"%@", request);
    
    AFHTTPRequestSerializer *serialier = [self requestSerializerWithRequest:request];
    
    NSURLSessionDataTask *dataTask = [self dataTaskWithSerializer:serialier method:method URLString:url parameters:body uploadProgress:^(NSProgress *uploadProgress) {
        if (request.uploadProgressBlock) {
            request.uploadProgressBlock(uploadProgress);
        }
    } downloadProgress:^(NSProgress *downloadProgress) {
        if (request.downloadProgressBlock) {
            request.downloadProgressBlock(downloadProgress);
        }
    } success:^(NSURLSessionDataTask *dataTask, id resp) {
        [self removeSessionTaskForKey:requestKey];
        [self requestSuccess:request dataTask:dataTask respData:resp];
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [self removeSessionTaskForKey:requestKey];
        [self requestFailure:request dataTask:dataTask error:error];
    }];
    
    request.requestTask = dataTask;
    
    [self setSesssionTask:dataTask forKey:requestKey];
    
    [dataTask resume];
}

- (void)cancelRequest:(IBURLRequest *)request
{
    NSString *requestKey = [IBEncode md5WithString:request.url];
    NSURLSessionDataTask *dataTask = [self sessionTaskForKey:requestKey];
    [dataTask cancel];
    [self removeSessionTaskForKey:requestKey];
    [request clearBlock];
}

- (void)cancelAllOperations
{
    [self.manager.operationQueue cancelAllOperations];
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

- (NSURLSessionDataTask *)dataTaskWithSerializer:(AFHTTPRequestSerializer *)serializer
                                          method:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [serializer requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
            failure(nil, serializationError);
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

// 容错处理
- (BOOL)tolerateRequest:(IBURLRequest *)request key:(NSString *)requestKey
{
    BOOL result = NO;
    NSString *errmsg;
    NSURLSessionDataTask *oldTask = [self sessionTaskForKey:requestKey];
    if (oldTask) { // 去除重复网络请求
        result = YES;
        errmsg = @"重复请求";
    }
    
    if (kIsEmptyString(request.url)) { // 请求url为空
        result = YES;
        errmsg = @"请求url为空";
    }
    
    if (result) {
        NSError *error = [NSError errorWithDomain:errmsg code:IBRequestError userInfo:nil];
        [self requestFailure:request dataTask:nil error:error];
    }
    
    return result;
}

- (void)requestSuccess:(IBURLRequest *)request dataTask:(NSURLSessionDataTask *)dataTask respData:(NSData *)respData
{
    if (!request.successBlock) {
        [request clearBlock];
        return;
    }
    IBURLResponse *response = request.response;
    response.errorCode = IBSUCCESS;
    response.task = dataTask;
    response.data = respData;
    [response parseResponse];
    dispatch_async(dispatch_get_main_queue(), ^{
        request.successBlock(response);
        [request clearBlock];
    });
}

- (void)requestFailure:(IBURLRequest *)request dataTask:(NSURLSessionDataTask *)dataTask error:(NSError *)error
{
    if (!request.failureBlock) {
        [request clearBlock];
        return;
    }
    IBErrorCode code = error.code == NSURLErrorTimedOut ? IBTimeout : error.code;
    IBURLResponse *response = request.response;
    response.errorMsg = error.localizedDescription;
    response.errorCode = code;
    response.task = dataTask;
    dispatch_async(dispatch_get_main_queue(), ^{
        request.failureBlock(response);
        [request clearBlock];
    });
}

- (NSURLSessionDataTask *)sessionTaskForKey:(NSString *)key
{
    if (kIsEmptyString(key)) {
        return nil;
    }
    EngineLock;
    NSURLSessionDataTask *dataTask = [self.sessionTasks objectForKey:key];
    EngineUnlock;
    return dataTask;
}

- (void)removeSessionTaskForKey:(NSString *)key
{
    if (kIsEmptyString(key)) {
        return;
    }
    EngineLock;
    [self.sessionTasks removeObjectForKey:key];
    EngineUnlock;
}

- (void)setSesssionTask:(NSURLSessionDataTask *)task forKey:(NSString *)key
{
    if (kIsEmptyObject(task) || kIsEmptyString(key)) {
        return;
    }
    EngineLock;
    [self.sessionTasks setObject:task forKey:key];
    EngineUnlock;
}

- (NSString *)methodStringWithType:(IBHTTPMethod)method
{
    NSString *methodString;
    switch (method) {
        case IBHTTPMethodGET: methodString = @"GET"; break;
        case IBHTTPMethodPOST: methodString = @"POST"; break;
        case IBHTTPMethodPUT: methodString = @"PUT"; break;
        case IBHTTPMethodHEAD: methodString = @"HEAD"; break;
        case IBHTTPMethodPATCH: methodString = @"PATCH"; break;
        case IBHTTPMethodDELETE: methodString = @"DELETE"; break;
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
