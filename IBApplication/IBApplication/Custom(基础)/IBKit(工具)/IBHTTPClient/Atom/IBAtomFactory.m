//
//  IBAtomFactory.m
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBAtomFactory.h"
#import "IBNetworkStatus.h"
#import "IBNetworkConfig.h"

@interface IBAtomInfo ()

@property (nonatomic, copy) NSString *constantQuery; // 生成不变的query

@property (nonatomic, assign) time_t lastNetUpdateTime;

@end

@implementation IBAtomInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _license       = [IBNetworkConfig licenseCode];
        _channel       = [IBNetworkConfig channelCode];
        _clientVersion = [IBNetworkConfig clientVersion];
        _systemVersion = [IBNetworkConfig systemVersion];
        _proto         = [IBNetworkConfig protoVersion];
        _userAgent     = [IBNetworkConfig iPhoneType];
        _idfa          = [IBNetworkConfig idfa];
        _idfv          = [IBNetworkConfig idfv];
        _coordinate = CLLocationCoordinate2DMake(400.0, 400.0);
        [self createConstantQuery];
    }
    return self;
}

- (void)createConstantQuery
{
    NSMutableString *constQuery = [[NSMutableString alloc] init];
    [constQuery appendFormat:@"lc=%@",      NSStringNONil(_license)];
    [constQuery appendFormat:@"&ca=%@",     NSStringNONil(_channel)];
    [constQuery appendFormat:@"&cv=%@",     NSStringNONil(_clientVersion)];
    [constQuery appendFormat:@"&proto=%@",  NSStringNONil(_proto)];
    [constQuery appendFormat:@"&idfa=%@",   NSStringNONil(_idfa)];
    [constQuery appendFormat:@"&idfv=%@",   NSStringNONil(_idfv)];
    [constQuery appendFormat:@"&os=%@",     NSStringNONil(_systemVersion)];
    [constQuery appendFormat:@"&ua=%@",     NSStringNONil(_userAgent)];
    _constantQuery = constQuery;
}

/**
 拼接动态参数
 */
- (NSString *)dynamicQuery {

    _networkMode = [[IBNetworkStatus shareInstance] specificNetworkMode];
    
    NSMutableString *temp = [[NSMutableString alloc] initWithString:_constantQuery];

    [temp appendFormat:@"&conn=%@",  NSStringNONil(_networkMode)];
    [temp appendFormat:@"&uid=%@",   NSStringNONil(_userId)];
    [temp appendFormat:@"&sid=%@",   NSStringNONil(_sessionId)];
    if (CLLocationCoordinate2DIsValid(_coordinate)) {
        [temp appendFormat:@"&lat=%@",   [NSString stringWithFormat:@"%lf", _coordinate.latitude]];
        [temp appendFormat:@"&lng=%@",   [NSString stringWithFormat:@"%lf", _coordinate.longitude]];
    }
    
    return temp;
}

/**
 原子参数字典
 */
- (NSDictionary *)atomDict
{
    _networkMode = [[IBNetworkStatus shareInstance] specificNetworkMode];

    NSMutableDictionary *dict = @{}.mutableCopy;
    
    [dict setObject:NSStringNONil(_license) forKey:@"lc"];
    [dict setObject:NSStringNONil(_channel) forKey:@"ca"];
    [dict setObject:NSStringNONil(_clientVersion) forKey:@"cv"];
    [dict setObject:NSStringNONil(_proto) forKey:@"proto"];
    [dict setObject:NSStringNONil(_idfa) forKey:@"idfa"];
    [dict setObject:NSStringNONil(_idfv) forKey:@"idfv"];
    [dict setObject:NSStringNONil(_systemVersion) forKey:@"os"];
    [dict setObject:NSStringNONil(_userAgent) forKey:@"ua"];
    [dict setObject:NSStringNONil(_networkMode) forKey:@"cnn"];
    [dict setObject:NSStringNONil(_userId) forKey:@"uid"];
    [dict setObject:NSStringNONil(_sessionId) forKey:@"sid"];
    
    if (CLLocationCoordinate2DIsValid(_coordinate)) {
        [dict setObject:[NSString stringWithFormat:@"%lf", _coordinate.latitude] forKey:@"lat"];
        [dict setObject:[NSString stringWithFormat:@"%lf", _coordinate.longitude] forKey:@"lng"];
    }
    
    return dict;
}

@end

@interface IBAtomFactory ()

@property (nonatomic, strong) IBAtomInfo *atom;
@property (nonatomic) dispatch_queue_t serialQueue;

@end

@implementation IBAtomFactory

+ (instancetype)sharedInstance
{
    static IBAtomFactory *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[IBAtomFactory alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _atom = [[IBAtomInfo alloc] init];
        _serialQueue = dispatch_queue_create("com.bowen.atom.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)updateCoordinate:(CLLocationCoordinate2D)coord {
    dispatch_sync(self.serialQueue, ^{
        if (CLLocationCoordinate2DIsValid(coord)) {
            self.atom.coordinate = coord;
        }
    });
}

- (void)updateUserId:(NSString *)userId sessionId:(NSString *)sessionId
{
    dispatch_sync(self.serialQueue, ^{
        self.atom.userId = userId;
        self.atom.sessionId = sessionId;
    });
}

- (NSString *)appendAtomParams:(NSString *)url
{
   __block NSString *query;
    dispatch_sync(self.serialQueue, ^{
        query = [self.atom dynamicQuery];
    });
    
    NSString *symbol = @"?";
    if ([url containsString:@"?"]) {
        symbol = @"&";
    }
    
    url = [url stringByAppendingString:symbol];
    url = [url stringByAppendingString:query];
    
    return url;
}

- (NSString *)enterUrl
{
    return [IBNetworkConfig enterUrl];
}

- (NSString *)backupEnterUrl
{
    return [IBNetworkConfig backupUrl];
}

- (void)clear
{
    [self updateUserId:@"" sessionId:@""];
}

#pragma mark - getter

- (NSDictionary *)atomDict {
    __block NSDictionary *dict;
    dispatch_sync(self.serialQueue, ^{
        dict = [self.atom atomDict];
    });
    return dict;
}

@end
