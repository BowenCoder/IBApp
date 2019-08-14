//
//  IBHTTPManager.m
//  IBApplication
//
//  Created by Bowen on 2019/6/17.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBHTTPManager.h"
#import "YYCache.h"
#import "IBMacros.h"
#import "IBHelper.h"
#import "MBLogger.h"
#import "IBEncode.h"
#import "AFNetworkActivityIndicatorManager.h"

#define kHttpCachePath @"HttpCache"

#define kHttpDiskCacheTime 24 * 60 * 60  // 缓存过期时间
#define kHttpMemoryCacheCountLimit 50
#define kHttpMemoryCacheCostLimit 2 * 1024 * 1024
#define kHttpDiskCacheCountLimit 200
#define kHttpDiskCacheCostLimit 10 * 1024 * 1024

#define kHttpRequestTimeout 10

@interface IBHTTPManager ()

@property (nonatomic, strong) YYCache *httpCache;
@property (nonatomic, strong) dispatch_queue_t httpQueue;
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *requestBlocks;

@end

@implementation IBHTTPManager

+ (instancetype)sharedInstance
{
    static IBHTTPManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[IBHTTPManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)initData
{
    _manager = [AFHTTPSessionManager manager];
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    _requestBlocks = [[NSMutableDictionary alloc] init];
    
    _httpQueue = dispatch_queue_create("com.bowen.http.manager.queue", NULL);
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:kHttpCachePath];
    _httpCache = [[YYCache alloc] initWithPath:path];
    _httpCache.memoryCache.countLimit = kHttpMemoryCacheCountLimit;
    _httpCache.memoryCache.costLimit = kHttpMemoryCacheCostLimit;
    _httpCache.diskCache.countLimit = kHttpDiskCacheCountLimit;
    _httpCache.diskCache.costLimit = kHttpDiskCacheCostLimit;
}

#pragma mark - 类方法

+ (void)GET:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletionBlock)completion
{
    IBRequest *request = [[IBRequest alloc] init];
    request.url = url;
    request.params = params;
    [[IBHTTPManager sharedInstance] GET:request completion:^(id<IBResponseProtocol> response) {
        completion(response.errorCode, response.errorMsg, response.dict);
    }];
}

+ (void)GETWithoutAtom:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletionBlock)completion
{
    IBRequest *request = [[IBRequest alloc] init];
    request.url = url;
    request.params = params;
    request.isAllowAtom = NO;
    [[IBHTTPManager sharedInstance] GET:request completion:^(id<IBResponseProtocol> response) {
        completion(response.errorCode, response.errorMsg, response.dict);
    }];
}

+ (void)GET:(NSString *)url params:(NSDictionary *)params cacheType:(IBHttpCacheType)cacheType cacheTime:(NSUInteger)secs timeout:(NSUInteger)interval completion:(IBHTTPCompletionBlock)completion
{
    IBRequest *request = [[IBRequest alloc] init];
    request.url = url;
    request.params = params;
    request.cacheType = cacheType;
    request.cacheTime = secs;
    request.timeoutInterval = interval;
    [[IBHTTPManager sharedInstance] GET:request completion:^(id<IBResponseProtocol> response) {
        completion(response.errorCode, response.errorMsg, response.dict);
    }];
}

+ (void)GETRetry:(NSString *)url params:(NSDictionary *)params cacheType:(IBHttpCacheType)cacheType cacheTime:(NSUInteger)secs timeout:(NSUInteger)interval completion:(IBHTTPCompletionBlock)completion
{
    IBRequest *request = [[IBRequest alloc] init];
    request.url = url;
    request.params = params;
    request.cacheType = cacheType;
    request.cacheTime = secs;
    request.retryTimes = 3;
    request.timeoutInterval = interval;
    [[IBHTTPManager sharedInstance] GET:request completion:^(id<IBResponseProtocol> response) {
        completion(response.errorCode, response.errorMsg, response.dict);
    }];
}

+ (void)POST:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body completion:(IBHTTPCompletionBlock)completion
{
    IBRequest *request = [[IBRequest alloc] init];
    request.url = url;
    request.params = params;
    request.body = body;
    [[IBHTTPManager sharedInstance] POST:request completion:^(id<IBResponseProtocol> response) {
        completion(response.errorCode, response.errorMsg, response.dict);
    }];
}

+ (void)POSTWithoutAtom:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body completion:(IBHTTPCompletionBlock)completion
{
    IBRequest *request = [[IBRequest alloc] init];
    request.url = url;
    request.params = params;
    request.body = body;
    request.isAllowAtom = NO;
    [[IBHTTPManager sharedInstance] POST:request completion:^(id<IBResponseProtocol> response) {
        completion(response.errorCode, response.errorMsg, response.dict);
    }];

}

+ (void)POST:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body timeout:(NSUInteger)interval completion:(IBHTTPCompletionBlock)completion
{
    IBRequest *request = [[IBRequest alloc] init];
    request.url = url;
    request.params = params;
    request.body = body;
    request.timeoutInterval = interval;
    [[IBHTTPManager sharedInstance] POST:request completion:^(id<IBResponseProtocol> response) {
        completion(response.errorCode, response.errorMsg, response.dict);
    }];
}

+ (void)POSTRetry:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body timeout:(NSUInteger)interval completion:(IBHTTPCompletionBlock)completion
{
    IBRequest *request = [[IBRequest alloc] init];
    request.url = url;
    request.params = params;
    request.body = body;
    request.retryTimes = 3;
    request.timeoutInterval = interval;
    [[IBHTTPManager sharedInstance] POST:request completion:^(id<IBResponseProtocol> response) {
        completion(response.errorCode, response.errorMsg, response.dict);
    }];
}

#pragma mark - IBHTTPManagerProtocol

- (void)GET:(id<IBRequestProtocol>)request completion:(IBResponseBlock)completion
{
    [self GET:request response:[[IBResponse alloc] init] completion:completion];
}

- (void)GET:(id<IBRequestProtocol>)request response:(id<IBResponseProtocol>)resp completion:(IBResponseBlock)completion
{
    request.requestType = IBRequestTypeGet;
    [self _retryRequest:request resp:resp isRetry:NO completion:^(id<IBResponseProtocol> response) {
        [IBHTTPManager _handleResponse:response completion:completion];
    }];
}

- (void)POST:(id<IBRequestProtocol>)request completion:(IBResponseBlock)completion
{
    [self POST:request response:[[IBResponse alloc] init] completion:completion];
}

- (void)POST:(id<IBRequestProtocol>)request response:(id<IBResponseProtocol>)resp completion:(IBResponseBlock)completion
{
    request.requestType = IBRequestTypePost;
    [self _retryRequest:request resp:resp isRetry:NO completion:^(id<IBResponseProtocol> response) {
        [IBHTTPManager _handleResponse:response completion:completion];
    }];
}

#pragma mark - 私有方法

- (void)_retryRequest:(id<IBRequestProtocol>)request resp:(id<IBResponseProtocol>)resp isRetry:(BOOL)isRetry completion:(IBResponseBlock)completion
{
    @weakify(self)
    
    request.retryTimes -= 1;

    [self _request:request resp:resp isRetry:isRetry completion:^(id<IBResponseProtocol> response) {
        @strongify(self)
        IBErrorCode errorCode = response.errorCode;
        if (errorCode != IBSUCCESS && request.retryTimes > 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(request.retryInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self _retryRequest:request resp:response isRetry:YES completion:completion];
            });
        } else {
            completion(response);
        }
    }];
}

- (void)_request:(id<IBRequestProtocol>)request resp:(id<IBResponseProtocol>)resp isRetry:(BOOL)isRetry completion:(IBResponseBlock)completion
{
    @weakify(self);
    
    BOOL isError = [self _handlerRequestError:request resp:resp completion:completion];
    if (isError) {
        return;
    }
    
    if (!isRetry) {
        [self _buildRequestUrl:request];
    }
    
    MBLog(@"#网络请求# url is: %@", request.url);
    
    dispatch_async(self.httpQueue, ^{
        @strongify(self);
        
        NSString *url        = request.url;
        NSString *requestKey = [IBEncode md5WithString:url];
        
        if (![self.requestBlocks objectForKey:requestKey]) {
            
            [self _addCompletionWithKey:requestKey resp:resp completion:completion];
            
            NSArray *cacheArray;
            if (request.cacheTime > 0) {
                cacheArray = (NSArray *)[self.httpCache objectForKey:requestKey];
            }
            if (cacheArray) {
                NSDate *expireTime  = (NSDate *)(cacheArray.firstObject);
                NSTimeInterval interval = [expireTime timeIntervalSinceNow];
                
                if (interval > 0 || request.cacheType == IBHttpCacheTypeCache) {
                    MBLog(@"#网络请求# hit the cache, key = %@", requestKey);
                    [self _requestSuccessWithKey:requestKey task:nil data:cacheArray[1] cacheTime:request.cacheTime];
                    return;
                }
            }
            
            NSTimeInterval timeout = request.timeoutInterval;
            IBRequestType requestType = request.requestType;
            self.manager.requestSerializer.timeoutInterval = timeout;
            
            switch (requestType) {
                case IBRequestTypeGet:
                    [self _GET:url secs:request.cacheTime requestKey:requestKey];
                    break;
                case IBRequestTypePost:
                    [self _POST:url body:request.body requestKey:requestKey];
                    break;
                default:
                    break;
            }
        } else {
            [self _addCompletionWithKey:requestKey resp:resp completion:completion];
        }
    });
}

- (BOOL)_handlerRequestError:(id<IBRequestProtocol>)request resp:(id<IBResponseProtocol>)response completion:(IBResponseBlock)completion
{
    BOOL isError = NO;
    
    if (kIsEmptyObject(request) || kIsEmptyObject(response)) {
        MBLogE(@"#网络请求# this is invalid request");
        response.errorCode = IBArgumentError;
        response.errorMsg = @"this is invalid request";
        isError = YES;
    } else {
        if (kIsEmptyString(request.url)) {
            MBLogE(@"#网络请求# url is nil....");
            response.errorCode = IBURLError;
            response.errorMsg = @"url is nil";
            isError = YES;
        }
    }
    
    if (completion) {
        completion(response);
    }
    
    return isError;
}

+ (void)_handleResponse:(id<IBResponseProtocol>)response completion:(IBResponseBlock)completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _handleResponseError:response];
        if (completion) {
            completion(response);
        }
    });
}

+ (void)_handleResponseError:(id<IBResponseProtocol>)response
{
    if (response.errorCode == IBSessionError) {
        //TODO:
    }
}

- (void)_GET:(NSString *)url secs:(NSUInteger)secs requestKey:(NSString *)requestKey
{
    [_manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self _requestSuccessWithKey:requestKey task:task data:responseObject cacheTime:secs];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self _requestFailureWithKey:requestKey task:task error:error];
    }];
}

- (void)_POST:(NSString *)url body:(NSDictionary *)body requestKey:(NSString *)requestKey
{
    [_manager POST:url parameters:body progress:^(NSProgress *uploadProgress) {
    
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self _requestSuccessWithKey:requestKey task:task data:responseObject cacheTime:0];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self _requestFailureWithKey:requestKey task:task error:error];
    }];
}

- (void)_requestSuccessWithKey:(NSString *)requestKey task:(NSURLSessionDataTask *)task data:(NSData *)data cacheTime:(NSUInteger)secs
{
    @weakify(self)
    dispatch_async(self.httpQueue, ^{
        @strongify(self)
        
        if (secs > 0) {
            [self _addCacheItemWithKey:requestKey data:data cacheTime:secs];
        }
        
        NSMutableArray *blocks = [self _blocksForKey:requestKey];
        
        if (!kIsEmptyArray(blocks)) {
            
            [self.requestBlocks removeObjectForKey:requestKey];
            
            for (NSDictionary *dict in blocks) {
                IBResponseBlock completion = [dict objectForKey:@"completion"];
                id<IBResponseProtocol> response = [dict objectForKey:@"response"];
                response.errorCode = IBSUCCESS;
                response.data = data;
                response.task = task;
                [response parseResponse];
                if (completion) {
                    completion(response);
                }
            }
        }
    });
}

- (void)_requestFailureWithKey:(NSString *)requestKey task:(NSURLSessionDataTask *)task error:(NSError *)error
{
    @weakify(self)
    dispatch_async(self.httpQueue, ^{
        @strongify(self)
        
        NSMutableArray *blocks = [self _blocksForKey:requestKey];
        
        if (!kIsEmptyArray(blocks)) {
            
            [self.requestBlocks removeObjectForKey:requestKey];
            
            IBErrorCode errCode = error.code;
            if (errCode == 0) {
                errCode = IBOtherError;
            }
            if (error.code == NSURLErrorTimedOut) {
                errCode = IBTimeout;
            }
            
            NSString *errMsg = error.localizedDescription;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSDictionary *dict in blocks) {
                    IBResponseBlock completion = [dict objectForKey:@"completion"];
                    id<IBResponseProtocol> response = [dict objectForKey:@"response"];
                    response.errorCode = errCode;
                    response.errorMsg = errMsg;
                    response.task = task;
                    if (completion) {
                        completion(response);
                    }
                }
            });
        }
    });
}

- (void)_addCacheItemWithKey:(NSString *)key data:(NSData *)data cacheTime:(NSUInteger)secs
{
    NSDate *expireTime = [NSDate dateWithTimeIntervalSinceNow:secs];
    NSArray *cacheItem = [NSArray arrayWithObjects:expireTime, data, nil];
    [_httpCache setObject:cacheItem forKey:key];
}

- (void)_addCompletionWithKey:(NSString *)requestKey resp:(id<IBResponseProtocol>)resp completion:(IBResponseBlock)block
{
    NSDictionary *dict = @{@"response" : resp, @"completion": block};
    
    NSMutableArray<NSDictionary *> *blocks =  [self.requestBlocks objectForKey:requestKey];

    if (!blocks) {
        blocks = [NSMutableArray array];
        self.requestBlocks[requestKey] = blocks;
    }
    
    [blocks addObject:dict];
}

- (NSMutableArray<NSDictionary *> *)_blocksForKey:(NSString *)requestKey
{
    NSMutableArray<NSDictionary *> *blocks = [self.requestBlocks objectForKey:requestKey];
    
    if (kIsEmptyArray(blocks)) {
        return nil;
    } else {
        return blocks;
    }
}

- (void)_buildRequestUrl:(id<IBRequestProtocol>)request
{
    NSString *url = [request.url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    request.url = [IBHelper fullURL:url params:request.params];
    
    if ([request respondsToSelector:@selector(appendAtomParams)]) {
        [request appendAtomParams];
    }
    
    if ([request respondsToSelector:@selector(encryptUrl)]) {
        [request encryptUrl];
    }
}

@end

@implementation IBHTTPManager (Ext)

- (void)cancelAllOperations
{
    [self.manager.operationQueue cancelAllOperations];
}

- (void)removeHttpCaches
{
    dispatch_async(self.httpQueue, ^{
        [self.httpCache removeAllObjects];
    });
}

- (void)openNetworkActivityIndicator:(BOOL)open {
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}

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

@end
