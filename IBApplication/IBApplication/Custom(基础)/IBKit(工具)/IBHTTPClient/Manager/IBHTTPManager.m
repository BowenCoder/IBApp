//
//  IBHTTPManager.m
//  IBApplication
//
//  Created by Bowen on 2019/6/17.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBHTTPManager.h"
#import "YYCache.h"

#define kHttpCachePath @"httpCache"
#define kHttpDiskCacheTime 24 * 60 * 60  // 缓存过期时间
#define kHttpMemoryCacheCountLimit 50
#define kHttpMemoryCacheCostLimit 1 * 1024 * 102
#define kHttpDiskCacheCountLimit 50
#define kHttpDiskCacheCostLimit 1 * 1024 * 102

@interface IBHTTPManager ()

@property (nonatomic, strong) YYCache *httpCache;
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary  *requestBlocks;

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
        _manager = [AFHTTPSessionManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _requestBlocks = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

@end
