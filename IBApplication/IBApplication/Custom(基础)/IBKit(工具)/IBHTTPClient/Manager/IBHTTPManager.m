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

- (void)GET:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletionBlock)completion
{
    
}

- (void)GETWithoutAtom:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletionBlock)completion
{
    
}

- (void)GET:(NSString *)url params:(NSDictionary *)params cacheType:(IBHttpCacheType)cacheType cacheTime:(NSUInteger)secs timeout:(NSUInteger)interval completion:(IBHTTPCompletionBlock)completion
{
    
}

- (void)GETRetry:(NSString *)url params:(NSDictionary *)params cacheType:(IBHttpCacheType)cacheType cacheTime:(NSUInteger)secs timeout:(NSUInteger)interval completion:(IBHTTPCompletionBlock)completion
{
    
}

- (void)POST:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body completion:(IBHTTPCompletionBlock)completion
{
    
}

- (void)POST:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body timeout:(NSUInteger)interval completion:(IBHTTPCompletionBlock)completion
{
    
}

- (void)POSTRetry:(NSString *)url params:(NSDictionary *)params body:(NSDictionary *)body timeout:(NSUInteger)interval completion:(IBHTTPCompletionBlock)completion
{
    
}


#pragma mark - IBHTTPManagerProtocol

- (void)get:(id<IBRequestProtocol>)request completion:(IBResponseBlock)completion
{
    
}

- (void)get:(id<IBRequestProtocol>)request response:(id<IBResponseProtocol>)response completion:(IBResponseBlock)completion
{
    
}

- (void)postJson:(id<IBPostJsonRequestProtocol>)request completion:(IBResponseBlock)completion
{
    
}

- (void)postJson:(id<IBPostJsonRequestProtocol>)request response:(id<IBResponseProtocol>)response completion:(IBResponseBlock)completion
{
    
}

- (void)postBinary:(id<IBPostBinaryRequestProtocol>)request completion:(IBResponseBlock)completion
{
    
}

- (void)postBinary:(id<IBPostBinaryRequestProtocol>)request response:(id<IBResponseProtocol>)response completion:(IBResponseBlock)completion
{
    
}

#pragma mark - 私有方法

- (void)_request:(id<IBRequestProtocol>)request requestType:(IBRequestType)requestType isByRetry:(BOOL)isByRetry completion:(IBHTTPResponseBlock)completion
{
    @weakify(self);
    if (kIsEmptyObject(request) || kIsEmptyString(request.url)) {
        MBLogE(@"#网络请求# url is nil....");
        completion(IBOtherError, @"url is invalid", nil);
        return;
    }
    
    [self _buildRequestUrl:request];
    
    MBLog(@"#网络请求# url is: %@", request.url);
    
    dispatch_async(self.httpQueue, ^{
        @strongify(self);
        
        NSString *url        = request.url;
        NSString *requestKey = [self _requestMD5:request];
        
        if (![self.requestBlocks objectForKey:requestKey]) {
            
            [self _addRequestBlockWithKey:requestKey completion:completion];
            
            id cacheObj = request.cacheTime > 0 ? [self.httpCache objectForKey:requestKey] : nil;
            if (cacheObj) {
                
                NSArray *cacheArray = (NSArray *)cacheObj;
                NSDate *expireTime  = (NSDate *)(cacheArray.firstObject);
                NSTimeInterval interval = [expireTime timeIntervalSinceNow];
                
                if (interval > 0 || request.cacheType == IBHttpCacheTypeCache) {
                    MBLog(@"#网络请求# hit the cache, key = %@", requestKey);
                    [self _requestSuccessWithKey:requestKey task:nil data:cacheArray[1] cacheTime:request.cacheTime];
                    return;
                }
            }
            
            NSTimeInterval timeout = request.timeoutInterval > 0 ? request.timeoutInterval : kHttpRequestTimeout;
            self.manager.requestSerializer.timeoutInterval = timeout;
            
            switch (requestType) {
                    case IBRequestTypeGet:
                    [self _GET:url query:nil secs:request.cacheTime requestKey:requestKey];
                    break;
                    
                    case IBRequestTypePostJson: {
                        id<IBPostJsonRequestProtocol> jsonRequest = (id<IBPostJsonRequestProtocol>)request;
                        [self _POSTJSON:url query:nil body:jsonRequest.body requestKey:requestKey];
                    }
                    break;
                    
                    case IBRequestTypePostBinary: {
                        id<IBPostBinaryRequestProtocol> binaryRequest = (id<IBPostBinaryRequestProtocol>)request;
                        [self _POST:url query:nil body:binaryRequest.body requestKey:requestKey];
                    }
                    break;
                    
                default:
                    break;
            }
        } else {
            [self _addRequestBlockWithKey:requestKey completion:completion];
        }
    });
}

- (void)_GET:(NSString *)url query:(NSString *)query secs:(int)secs requestKey:(NSString *)requestKey
{
    [_manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self _requestSuccessWithKey:requestKey task:task data:responseObject cacheTime:secs];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self _requestFailureWithKey:requestKey task:task error:error];
    }];
}

- (void)_POSTJSON:(NSString *)url query:(NSString *)query body:(NSDictionary *)body requestKey:(NSString *)requestKey
{
    NSString *urlStr = [IBHelper fullURL:url paramStr:query];
    
    [_manager POST:urlStr parameters:body progress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self _requestSuccessWithKey:requestKey task:task data:responseObject cacheTime:0];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self _requestFailureWithKey:requestKey task:task error:error];
    }];
}

- (void)_POST:(NSString *)url query:(NSString *)query body:(NSData *)body requestKey:(NSString *)requestKey
{
    NSString *urlStr = [IBHelper fullURL:url paramStr:query];
    NSURL *uploadUrl = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:uploadUrl];
    [request setHTTPMethod:@"POST"];
    
    __block NSURLSessionUploadTask *uploadTask = nil;
    uploadTask = [_manager uploadTaskWithRequest:request fromData:body progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (!error) {
            [self _requestSuccessWithKey:requestKey task:uploadTask data:responseObject cacheTime:0];
        } else {
            [self _requestFailureWithKey:requestKey task:uploadTask error:error];
        }
    }];
    
    [uploadTask resume];
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
            
            dispatch_async(dispatch_get_main_queue(), ^{
                for (IBHTTPResponseBlock block in blocks) {
                    block(IBSUCCESS, @"", data);
                }
            });
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
                for (IBHTTPResponseBlock block in blocks) {
                    block(errCode, NSStringNONil(errMsg), [NSData new]);
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

- (void)_addRequestBlockWithKey:(NSString *)requestKey completion:(IBHTTPResponseBlock)block
{
    NSMutableArray<IBHTTPResponseBlock> *blocks =  [self.requestBlocks objectForKey:requestKey];

    if (!blocks) {
        blocks = [NSMutableArray new];
        self.requestBlocks[requestKey] = blocks;
    }
    
    [blocks addObject:block];
}

- (NSMutableArray<IBHTTPResponseBlock> *)_blocksForKey:(NSString *)requestKey
{
    NSMutableArray<IBHTTPResponseBlock> *blocks = [self.requestBlocks objectForKey:requestKey];
    
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

- (NSString *)_requestMD5:(id<IBRequestProtocol>)request
{
    NSString *key = [IBEncode md5WithString:request.url];
    return key;
}




@end
