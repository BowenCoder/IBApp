//
//  IBHTTPCache.m
//  IBApplication
//
//  Created by Bowen on 2019/12/11.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBHTTPCache.h"
#import "YYCache.h"

@interface IBHTTPCache ()

@property (nonatomic, strong) YYCache *cache;

@end

@implementation IBHTTPCache

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
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [file stringByAppendingPathComponent:@"networkCache"];
    self.cache = [[YYCache alloc] initWithPath:path];
    self.cache.memoryCache.countLimit = 50;
    self.cache.memoryCache.costLimit =  2 * 1024 * 1024;
    self.cache.diskCache.countLimit = 200;
    self.cache.diskCache.costLimit = 10 * 1024 * 1024;
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key cacheTime:(NSTimeInterval)time
{
    NSDate *expireTime = [NSDate dateWithTimeIntervalSinceNow:time];
    NSArray *cacheItem = [NSArray arrayWithObjects:expireTime, object, nil];
    [self.cache setObject:cacheItem forKey:key];
}

- (void)objectForKey:(NSString *)key withBlock:(void(^)(id<NSCoding> object))block cacheTime:(NSTimeInterval)time
{
    if (![self containsObjectForKey:key]) {
        return;
    }
    
    [self.cache objectForKey:key withBlock:^(NSString *key, id<NSCoding> object) {
        NSArray *cacheArray = (NSArray *)object;
        NSDate *expireTime  = (NSDate *)(cacheArray.firstObject);
        NSTimeInterval interval = [expireTime timeIntervalSinceNow];
        if (interval > 0 && cacheArray.count > 1) {
            block(cacheArray[1]);
        } else {
            [self removeObjectForKey:key withBlock:nil];
        }
    }];
}

- (void)removeAllCaches
{
    [self.cache removeAllObjects];
}

- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block
{
    [self.cache removeObjectForKey:key withBlock:block];
}

- (BOOL)containsObjectForKey:(NSString *)key
{
    return [self.cache containsObjectForKey:key];
}


@end
