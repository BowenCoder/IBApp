//
//  IBHTTPManager.m
//  IBApplication
//
//  Created by Bowen on 2019/12/10.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBHTTPManager.h"
#import "IBHTTPEngine.h"
#import "IBHTTPCache.h"
#import "MBLogger.h"

@interface IBHTTPManager ()

@property (nonatomic, strong) IBHTTPEngine *engine;
@property (nonatomic, strong) IBHTTPCache *cache;

@end

@implementation IBHTTPManager

+ (instancetype)sharedManager
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
        [self setupData];
    }
    return self;
}

- (void)setupData
{
    self.engine = [[IBHTTPEngine alloc] init];
    self.cache = [[IBHTTPCache alloc] init];
}

+ (void)GET:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.method = IBHTTPGET;
    [self sendRequest:request completion:completion];
}

+ (void)GETWithoutAtom:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.isAllowAtom = NO;
    request.method = IBHTTPGET;
    [self sendRequest:request completion:completion];
}

+ (void)GETRetry:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.retryTimes = 3.0;
    request.retryInterval = 5.0;
    request.method = IBHTTPGET;
    [self sendRequest:request completion:completion];
}

+ (void)GET:(NSString *)url params:(NSDictionary *)params cacheTime:(NSUInteger)secs timeout:(NSUInteger)interval completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.cacheTime = secs;
    request.timeoutInterval = interval;
    request.method = IBHTTPGET;
    [self sendRequest:request completion:completion];
}

+ (void)POST:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.body = body;
    request.isAllowAtom = NO;
    request.method = IBHTTPPOST;
    [self sendRequest:request completion:completion];
}

+ (void)POSTWithoutAtom:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.body = body;
    request.method = IBHTTPPOST;
    [self sendRequest:request completion:completion];
}

+ (void)POST:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body timeout:(NSUInteger)interval completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.body = body;
    request.timeoutInterval = interval;
    request.method = IBHTTPPOST;
    [self sendRequest:request completion:completion];
}

+ (void)POSTRetry:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body timeout:(NSUInteger)interval completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.body = body;
    request.timeoutInterval = interval;
    request.retryTimes = 3.0;
    request.retryInterval = 5.0;
    request.method = IBHTTPPOST;
    [self sendRequest:request completion:completion];
}

+ (void)sendRequest:(IBURLRequest *)request completion:(IBHTTPCompletion)completion
{
    [self cacheForRequest:request completion:completion];

    __weak typeof(request) weakRequest = request;
    request.completionHandler = ^(IBURLResponse *response) {
        __strong typeof(weakRequest) strongRequest = weakRequest;
        if (response.code != IBSUCCESS) {
            if (strongRequest.retryTimes > 0) {
                strongRequest.retryTimes--;
                CGFloat interval = strongRequest.retryInterval - strongRequest.retryTimes;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self sendRequest:strongRequest completion:completion];
                });
            } else {
                completion(response.code, response);
            }
        } else {
            [self cacheObjectForRequest:strongRequest resp:response.dict];
            completion(response.code, response);
        }
    };
    
    [[IBHTTPManager sharedManager].engine sendRequest:request];
}

+ (void)cancelAllOperations
{
    [[IBHTTPManager sharedManager].engine cancelAllOperations];
}

+ (void)removeHttpCaches
{
    [[IBHTTPManager sharedManager].cache removeAllCaches];
}

+ (void)openNetworkActivityIndicator:(BOOL)open
{
    [[IBHTTPManager sharedManager].engine openNetworkActivityIndicator:open];
}

+ (void)setSecurityPolicyWithCerName:(NSString *)name validatesDomainName:(BOOL)validatesDomainName
{
    [[IBHTTPManager sharedManager].engine setSecurityPolicyWithCerName:name validatesDomainName:validatesDomainName];
}

+ (void)cacheForRequest:(IBURLRequest *)request completion:(IBHTTPCompletion)completion
{
    [[IBHTTPManager sharedManager].cache objectForUrl:request.url withBlock:^(id<NSCoding> object) {
        MBLog(@"#网络请求# 命中缓存 url = %@", request.url);
        IBURLResponse *response = [IBURLResponse response];
        response.dict = (NSDictionary *)object;
        completion(IBSUCCESS, response);
    } cacheTime:request.cacheTime];
}

+ (void)cacheObjectForRequest:(IBURLRequest *)request resp:(NSDictionary *)dict
{
    [[IBHTTPManager sharedManager].cache setObject:dict forUrl:request.url cacheTime:request.cacheTime];
}

@end
