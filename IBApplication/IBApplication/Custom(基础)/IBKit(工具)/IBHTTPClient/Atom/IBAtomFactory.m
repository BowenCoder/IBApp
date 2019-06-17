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
    if (kIsString(_license)) {
        [constQuery appendFormat:@"lc=%@", _license];
    }
    if (kIsString(_channel)) {
        [constQuery appendFormat:@"&ca=%@", _channel];
    }
    if (kIsString(_clientVersion)) {
        [constQuery appendFormat:@"&cv=%@", _clientVersion];
    }
    if (kIsString(_proto)) {
        [constQuery appendFormat:@"&proto=%@", _proto];
    }
    if (kIsString(_idfa)) {
        [constQuery appendFormat:@"&idfa=%@", _idfa];
    }
    if (kIsString(_idfv)) {
        [constQuery appendFormat:@"&idfv=%@", _idfv];
    }
    if (kIsString(_systemVersion)) {
        [constQuery appendFormat:@"&os=%@", _systemVersion];
    }
    if (kIsString(_userAgent)) {
        [constQuery appendFormat:@"&ua=%@", _userAgent];
    }
    _constantQuery = constQuery;
}

/**
 拼接动态参数
 */
- (NSString *)dynamicQuery {

    _networkMode = [[IBNetworkStatus shareInstance] specificNetworkMode];
    
    NSMutableString *temp = [[NSMutableString alloc] initWithString:_constantQuery];

    if (kIsString(_networkMode)) {
        [temp appendFormat:@"&conn=%@", _networkMode];
    }
    if (CLLocationCoordinate2DIsValid(_coordinate)) {
        [temp appendFormat:@"&lat=%@",   [NSString stringWithFormat:@"%lf", _coordinate.latitude]];
        [temp appendFormat:@"&lng=%@",   [NSString stringWithFormat:@"%lf", _coordinate.longitude]];
    }
    
    return temp.copy;
}

/**
 原子参数字典
 */
- (NSDictionary *)atomDict
{
    _networkMode = [[IBNetworkStatus shareInstance] specificNetworkMode];

    NSMutableDictionary *dict = @{}.mutableCopy;
    
    if (kIsString(_license)) {
        [dict setObject:_license forKey:@"lc"];
    }
    if (kIsString(_channel)) {
        [dict setObject:_channel forKey:@"ca"];
    }
    if (kIsString(_clientVersion)) {
        [dict setObject:_clientVersion forKey:@"cv"];
    }
    if (kIsString(_proto)) {
        [dict setObject:NSStringNONil(_proto) forKey:@"proto"];
    }
    if (kIsString(_idfa)) {
        [dict setObject:_idfa forKey:@"idfa"];
    }
    if (kIsString(_idfv)) {
        [dict setObject:_idfv forKey:@"idfv"];
    }
    if (kIsString(_systemVersion)) {
        [dict setObject:_systemVersion forKey:@"os"];
    }
    if (kIsString(_userAgent)) {
        [dict setObject:_userAgent forKey:@"ua"];
    }
    if (kIsString(_networkMode)) {
        [dict setObject:_networkMode forKey:@"cnn"];
    }
    if (kIsString(_userId)) {
        [dict setObject:_userId forKey:@"uid"];
    }
    if (kIsString(_sessionId)) {
        [dict setObject:_sessionId forKey:@"sid"];
    }
    if (CLLocationCoordinate2DIsValid(_coordinate)) {
        [dict setObject:[NSString stringWithFormat:@"%lf", _coordinate.latitude] forKey:@"lat"];
        [dict setObject:[NSString stringWithFormat:@"%lf", _coordinate.longitude] forKey:@"lng"];
    }
    
    return dict;
}

- (void)setUserId:(NSString *)userId
{
    _userId = userId;
    _constantQuery = [_constantQuery stringByAppendingFormat:@"&uid=%@", userId];
}

- (void)setSessionId:(NSString *)sessionId
{
    _sessionId = sessionId;
    _constantQuery = [_constantQuery stringByAppendingFormat:@"&sid=%@", sessionId];
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
