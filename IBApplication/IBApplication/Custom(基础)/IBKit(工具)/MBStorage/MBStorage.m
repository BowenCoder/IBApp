//
//  MBStorage.m
//  IBApplication
//
//  Created by Bowen on 2019/8/12.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBStorage.h"
#import "YYCache.h"

@interface MBStorage ()

@property (nonatomic, strong) YYCache *cache;

@end

@implementation MBStorage

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MBStorage *storage;
    dispatch_once(&onceToken, ^{
        storage = [[self alloc] init];
    });
    return storage;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"com.bowen.storage"];
        self.cache = [[YYCache alloc] initWithPath:path];
        self.uid = @"none";
    }
    return self;
}

+ (id)objectForKey:(NSString *)key namespace:(NSString *)ns
{
    return [[MBStorage sharedInstance].cache objectForKey:[self combinedKey:key namespace:ns]];
}

+ (void)setObject:(id<NSCoding>)object forKey:(NSString *)key namespace:(NSString *)ns
{
    return [[MBStorage sharedInstance].cache setObject:object forKey:[self combinedKey:key namespace:ns]];
}

+ (void)removeObjectForKey:(NSString *)key namespace:(nonnull NSString *)ns
{
    [[MBStorage sharedInstance].cache removeObjectForKey:[self combinedKey:key namespace:ns]];
}

+ (void)removeAllObjects
{
    [[MBStorage sharedInstance].cache removeAllObjects];
}

+ (NSString *)combinedKey:(NSString *)key namespace:(NSString *)ns
{
    if (ns && ns.length > 0) {
        return [NSString stringWithFormat:@"%@_%@_%@",[MBStorage sharedInstance].uid, ns, key];
    } else {
        return [NSString stringWithFormat:@"%@_%@",[MBStorage sharedInstance].uid, key];
    }
}

@end
