//
//  IBUrlManager.m
//  IBApplication
//
//  Created by Bowen on 2019/6/30.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBUrlManager.h"
#import "IBNetworkConfig.h"
#import "IBMacros.h"
#import "IBEncode.h"
#import "NSDictionary+Ext.h"

@interface IBServiceInfoModel : NSObject

@property (nonatomic, strong) NSMutableDictionary *serviceUrls;
@property (nonatomic, strong) NSMutableDictionary *serviceSwitchs;

@property (nonatomic, copy) NSString *md5;

@end

@implementation IBServiceInfoModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serviceUrls = @{}.mutableCopy;
        _serviceSwitchs = @{}.mutableCopy;
    }
    return self;
}

+ (instancetype)modelWithDict:(NSDictionary *)dict old:(IBServiceInfoModel *)oldModel
{
    if (kIsEmptyDict(dict)) {
        return nil;
    }
    NSString    *md5  = [dict mb_stringForKey:@"md5"];
    BOOL    uptodate  = [[dict mb_numberForKey:@"uptodate"] boolValue]; // 是否全量更新
    NSArray *servers  = [dict mb_arrayForKey:@"servers"];
    NSArray *switches = [dict mb_arrayForKey:@"switches"];
    
    if (uptodate) { // 全量更新
        IBServiceInfoModel *model = [[IBServiceInfoModel alloc] init];
        model.md5 = md5;
        for (NSDictionary *item in servers) {
            [model.serviceUrls mb_setObject:item[@"url"] forKey:item[@"key"]];
        }
        for (NSDictionary *item in switches) {
            [model.serviceSwitchs mb_setObject:item[@"switch"] forKey:item[@"name"]];
        }
        return model;
        
    } else { // 增量更新
        if (!kIsEmptyString(md5)) {
            oldModel.md5 = md5;
        }
        for (NSDictionary *item in servers) {
            [oldModel.serviceUrls mb_setObject:item[@"url"] forKey:item[@"key"]];
        }
        for (NSDictionary *item in switches) {
            [oldModel.serviceSwitchs mb_setObject:item[@"switch"] forKey:item[@"name"]];
        }
        return oldModel;
    }
}

- (NSString *)urlFromKey:(NSString *)key
{
    return [self.serviceUrls mb_stringForKey:key];
}

- (BOOL)switchFromKey:(NSString *)key
{
    return [[self.serviceSwitchs mb_numberForKey:key] boolValue];
}

@end

@interface IBUrlManager ()

@property (nonatomic, strong) dispatch_queue_t urlQueue;

@property (nonatomic, strong) IBServiceInfoModel *onlineServerInfo;
@property (nonatomic, strong) IBServiceInfoModel *localServerInfo;

@end

@implementation IBUrlManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _urlQueue = dispatch_queue_create("com.bowen.url_manager_queue", NULL);;
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static IBUrlManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[IBUrlManager alloc] init];
    });
    return instance;
}

- (void)updateUrlConfig:(NSDictionary *)aConfig
{
    if (kIsEmptyDict(aConfig)) {
        return;
    }
    dispatch_sync(self.urlQueue, ^{
        self.onlineServerInfo = [IBServiceInfoModel modelWithDict:aConfig old:self.onlineServerInfo];
    });
}

- (NSString *)urlForKey:(NSString *)key
{
    __block NSString *url;
    dispatch_sync(self.urlQueue, ^{
        url = [self.onlineServerInfo urlFromKey:key];
        if (kIsEmptyString(url)) {
            url = [self.localServerInfo urlFromKey:key];
        }
    });
    return url;
}

- (BOOL)switchForKey:(NSString *)key
{
    __block BOOL isOpen = NO;
    dispatch_sync(self.urlQueue, ^{
        if (!kIsEmptyObject(self.onlineServerInfo)) {
            isOpen = [self.onlineServerInfo switchFromKey:key];
        } else {
            isOpen = [self.localServerInfo switchFromKey:key];
        }
    });
    return isOpen;
}

- (NSString *)scaleImageUrl:(NSString *)url size:(CGSize)size
{
    return [self scaleImageUrl:url size:size quality:80 useWebp:NO];
}

- (NSString *)scaleImageUrl:(NSString *)url size:(CGSize)size quality:(NSInteger)quality
{
    return [self scaleImageUrl:url size:size quality:quality useWebp:YES];
}

- (NSString *)scaleImageUrl:(NSString *)url size:(CGSize)size quality:(NSInteger)quality useWebp:(BOOL)useWebp {
    if (kIsEmptyString(url) && size.width <= 0 && size.height <= 0) {
        return @"";
    }
    
    NSString *scaleUrl = [self urlForKey:@"IMAGE_SCALE"];
    
    url = [NSString stringWithFormat:@"%@%@", NSStringNONil(scaleUrl), url];
    
    int width  = size.width;
    int height = size.height;
    
    int t = useWebp ? 1 : 0;
    
    return [NSString stringWithFormat:@"%@&w=%d&h=%d&s=%@&t=%d", url, width, height, @(quality), t];
}

- (NSString *)fullImageUrl:(NSString *)url
{
    NSString *prefix = [self urlForKey:@"IMAGE"];
    return [self fixUrlPath:url prefix:prefix];
}

- (NSString *)fullVideoUrl:(NSString *)url
{
    NSString *prefix = [self urlForKey:@"VIDEO"];
    return [self fixUrlPath:url prefix:prefix];
}

- (NSString *)fullVoiceUrl:(NSString *)url
{
    NSString *prefix = [self urlForKey:@"VOICE"];
    return [self fixUrlPath:url prefix:prefix];
}

- (NSString *)fixUrlPath:(NSString *)urlSuffix prefix:(NSString *)prefix {
    if (kIsEmptyString(urlSuffix) || kIsEmptyString(prefix)) {
        return nil;
    }
    
    if (!([urlSuffix hasPrefix:@"http://"] || [urlSuffix hasPrefix:@"https://"])) {
        NSURL *prefixUrl = [NSURL URLWithString:prefix];
        NSURL *url = [prefixUrl URLByAppendingPathComponent:urlSuffix];
        return url.absoluteString;
    }
    
    return urlSuffix;
}

#pragma mark - getter

- (IBServiceInfoModel *)localServerInfo {
    if(!_localServerInfo){
        _localServerInfo = [[IBServiceInfoModel alloc] init];
        dispatch_sync(self.urlQueue, ^{
            NSDictionary *serverInfo = [IBNetworkConfig serviceInfo];
            self.localServerInfo = [IBServiceInfoModel modelWithDict:serverInfo old:nil];
        });
    }
    return _localServerInfo;
}

@end
