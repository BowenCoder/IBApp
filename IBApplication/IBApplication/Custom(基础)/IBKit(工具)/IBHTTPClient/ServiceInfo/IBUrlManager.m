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
#import "IBNetApiKeyInner.h"
#import "IBServiceInfoModel.h"
#import "MBLogger.h"
#import "IBServiceInfoHandler.h"

@interface IBUrlManager ()

@property (nonatomic, strong) dispatch_queue_t urlQueue;

@property (nonatomic, strong) IBServiceInfoModel *model;

@property (nonatomic, strong) IBServiceInfoHandler *serviceInfo;

@end

@implementation IBUrlManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _urlQueue = dispatch_queue_create("com.bowen.url.manager.queue", NULL);;
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

- (void)prepare
{
    [self.serviceInfo loadServiceInfo];
}

- (NSDictionary *)updateUrlConfig:(NSDictionary *)aConfig
{
    __block NSDictionary *dict;
    dispatch_sync(self.urlQueue, ^{
       dict = [self.model refreshServiceInfo:aConfig];
    });
    return dict;
}

- (NSString *)urlForKey:(NSString *)key
{
    __block NSString *url;
    dispatch_sync(self.urlQueue, ^{
        url = [self.model urlFromKey:key];
        if (kIsEmptyString(url)) {
            MBLogE(@"url is nil, Key: %@", key);
        }
    });
    return url;
}

- (BOOL)switchForKey:(NSString *)key
{
    __block BOOL isOpen = NO;
    dispatch_sync(self.urlQueue, ^{
        isOpen = [self.model switchFromKey:key];
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
    
    NSString *scaleUrl = [self urlForKey:kNETImageScaleUrl];
    
    url = [NSString stringWithFormat:@"%@%@", NSStringNONil(scaleUrl), url];
    
    int width  = size.width;
    int height = size.height;
    
    int t = useWebp ? 1 : 0;
    
    return [NSString stringWithFormat:@"%@&w=%d&h=%d&s=%@&t=%d", url, width, height, @(quality), t];
}

- (NSString *)fullImageUrl:(NSString *)url
{
    NSString *prefix = [self urlForKey:kNETImagePrefixUrl];
    return [self fixUrlPath:url prefix:prefix];
}

- (NSString *)fullVideoUrl:(NSString *)url
{
    NSString *prefix = [self urlForKey:kNETVideoDownloadUrl];
    return [self fixUrlPath:url prefix:prefix];
}

- (NSString *)fullVoiceUrl:(NSString *)url
{
    NSString *prefix = [self urlForKey:kNETVoiceDownloadUrl];
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

- (IBServiceInfoModel *)model {
    if(!_model){
        _model = [[IBServiceInfoModel alloc] init];
    }
    return _model;
}

- (IBServiceInfoHandler *)serviceInfo {
    if(!_serviceInfo){
        _serviceInfo = [[IBServiceInfoHandler alloc] init];
    }
    return _serviceInfo;
}

@end
