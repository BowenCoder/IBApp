//
//  IBHTTPManager.m
//  IBApplication
//
//  Created by Bowen on 2019/12/10.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBHTTPManager.h"
#import "IBNetworkEngine.h"
#import "IBHTTPCache.h"
#import "IBSecurity.h"
#import "MBLogger.h"

@interface IBHTTPManager ()

@property (nonatomic, strong) IBNetworkEngine *engine;
@property (nonatomic, strong) IBHTTPCache *cache;
@property (nonatomic, strong) IBSecurity *security;

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
    self.engine = [IBNetworkEngine defaultEngine];
    self.cache = [[IBHTTPCache alloc] init];
    self.security = [[IBSecurity alloc] init];
}

+ (IBURLRequest *)GET:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.method = IBHTTPGET;
    [self sendRequest:request completion:completion];
    return request;
}

+ (IBURLRequest *)GETWithoutAtom:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.isAllowAtom = NO;
    request.method = IBHTTPGET;
    [self sendRequest:request completion:completion];
    return request;
}

+ (IBURLRequest *)GETRetry:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.retryTimes = 3.0;
    request.retryInterval = 5.0;
    request.method = IBHTTPGET;
    [self sendRequest:request completion:completion];
    return request;
}

+ (IBURLRequest *)GET:(NSString *)url params:(NSDictionary *)params cacheTime:(NSUInteger)secs timeout:(NSUInteger)interval completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.cacheTime = secs;
    request.method = IBHTTPGET;
    request.timeoutInterval = interval ?: request.timeoutInterval;
    [self sendRequest:request completion:completion];
    return request;
}

+ (IBURLRequest *)POST:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.body = body;
    request.method = IBHTTPPOST;
    [self sendRequest:request completion:completion];
    return request;
}

+ (IBURLRequest *)POSTWithoutAtom:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.body = body;
    request.isAllowAtom = NO;
    request.method = IBHTTPPOST;
    [self sendRequest:request completion:completion];
    return request;
}

+ (IBURLRequest *)POST:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body timeout:(NSUInteger)interval completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.body = body;
    request.method = IBHTTPPOST;
    request.timeoutInterval = interval ?: request.timeoutInterval;
    [self sendRequest:request completion:completion];
    return request;
}

+ (IBURLRequest *)POSTRetry:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body timeout:(NSUInteger)interval completion:(IBHTTPCompletion)completion
{
    IBURLRequest *request = [[IBURLRequest alloc] init];
    request.url = url;
    request.params = params;
    request.body = body;
    request.retryTimes = 3.0;
    request.retryInterval = 5.0;
    request.method = IBHTTPPOST;
    request.timeoutInterval = interval ?: request.timeoutInterval;
    [self sendRequest:request completion:completion];
    return request;
}

+ (void)sendRequest:(IBURLRequest *)request completion:(IBHTTPCompletion)completion
{
    [self objectForRequest:request completion:completion];
    
    __weak typeof(request) weakSend = request;
    request.completionHandler = ^(IBURLResponse *response) {
        __strong typeof(weakSend) strongSend = weakSend;
        if (response.code == IBURLErrorSuccess) {
            completion(response.code, response);
            [self setObjectForRequest:strongSend resp:response.dict];
        } else {
            if (strongSend.retryTimes > 0) {
                strongSend.retryTimes--;
                CGFloat interval = strongSend.retryInterval - strongSend.retryTimes;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self sendRequest:strongSend completion:completion];
                });
            } else {
                completion(response.code, response);
            }
        }
    };
    
    request.headerFields = [[IBHTTPManager sharedManager].security headerFields];

    [[IBHTTPManager sharedManager].engine sendHTTPRequest:request];
}

#pragma mark - 其他操作

+ (void)cancelRequest:(IBURLRequest *)request
{
    [[IBHTTPManager sharedManager].engine cancelRequest:request];
}

+ (void)cancelAllTasks
{
    [[IBHTTPManager sharedManager].engine cancelAllTasks];
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

+ (void)objectForRequest:(IBURLRequest *)request completion:(IBHTTPCompletion)completion
{
    if (!request.cacheTime) {
        return;
    }
    [[IBHTTPManager sharedManager].cache objectForKey:[request cacheKey] withBlock:^(id<NSCoding> object) {
        MBLog(@"#network# name:hit.cache url:%@", request.url);
        IBURLResponse *response = [IBURLResponse response];
        response.dict = (NSDictionary *)object;
        completion(IBURLErrorSuccess, response);
    } cacheTime:request.cacheTime];
}

+ (void)setObjectForRequest:(IBURLRequest *)request resp:(NSDictionary *)dict
{
    if (!request.cacheTime) {
        return;
    }
    [[IBHTTPManager sharedManager].cache setObject:dict forKey:[request cacheKey] cacheTime:request.cacheTime];
}

@end
