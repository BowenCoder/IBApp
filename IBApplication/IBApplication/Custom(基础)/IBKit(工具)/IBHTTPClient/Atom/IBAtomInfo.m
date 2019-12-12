//
//  IBAtomInfo.m
//  IBApplication
//
//  Created by Bowen on 2019/12/12.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBAtomInfo.h"
#import "IBNetworkStatus.h"
#import "IBNetworkConfig.h"
#import "IBMacros.h"

@interface IBAtomInfo ()

@property (nonatomic, copy) NSString *constantQuery; // 生成不变的query

@end

@implementation IBAtomInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _license       = [IBNetworkConfig licenseCode];
        _channel       = [IBNetworkConfig channelCode];
        _clientVersion = [IBNetworkConfig clientVersion];
        _osVersion     = [IBNetworkConfig systemVersion];
        _proto         = [IBNetworkConfig protoVersion];
        _userAgent     = [IBNetworkConfig iPhoneType];
        _idfa          = [IBNetworkConfig idfa];
        _idfv          = [IBNetworkConfig idfv];
        _deviceName    = [IBNetworkConfig deviceName];
        _coordinate    = CLLocationCoordinate2DMake(400.0, 400.0);
        [self createConstantQuery];
    }
    return self;
}

- (void)createConstantQuery
{
    NSMutableString *constQuery = [[NSMutableString alloc] init];
    if (kIsString(_license)) { // 注意第一个参数不能为空
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
    if (kIsString(_osVersion)) {
        [constQuery appendFormat:@"&os=%@", _osVersion];
    }
    if (kIsString(_userAgent)) {
        [constQuery appendFormat:@"&ua=%@", _userAgent];
    }
    if (kIsString(_deviceName)) {
        [constQuery appendFormat:@"&device=%@", _deviceName];
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
    if (kIsString(self.userId)) {
        [temp appendFormat:@"&uid=%@", self.userId];
    }
    if (kIsString(self.sessionId)) {
        [temp appendFormat:@"&sid=%@", self.sessionId];
    }
    if (kIsString(self.smid)) {
        [temp appendFormat:@"&smid=%@", self.smid];
    }
    if (kIsString(self.logId)) {
        [temp appendFormat:@"&sid=%@", self.logId];
    }
    if (CLLocationCoordinate2DIsValid(_coordinate)) {
        [temp appendFormat:@"&lat=%@", [NSString stringWithFormat:@"%lf", _coordinate.latitude]];
        [temp appendFormat:@"&lng=%@", [NSString stringWithFormat:@"%lf", _coordinate.longitude]];
    }
    
    return temp.copy;
}

/**
 原子参数字典
 */
- (NSDictionary *)atomDict
{
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
        [dict setObject:_proto forKey:@"proto"];
    }
    if (kIsString(_idfa)) {
        [dict setObject:_idfa forKey:@"idfa"];
    }
    if (kIsString(_idfv)) {
        [dict setObject:_idfv forKey:@"idfv"];
    }
    if (kIsString(_osVersion)) {
        [dict setObject:_osVersion forKey:@"os"];
    }
    if (kIsString(_userAgent)) {
        [dict setObject:_userAgent forKey:@"ua"];
    }
    if (kIsString(_userId)) {
        [dict setObject:_userId forKey:@"uid"];
    }
    if (kIsString(_sessionId)) {
        [dict setObject:_sessionId forKey:@"sid"];
    }
    if (kIsString(self.smid)) {
        [dict setObject:_smid forKey:@"smid"];
    }
    if (kIsString(self.logId)) {
        [dict setObject:_logId forKey:@"logid"];
    }
    if (kIsString(self.deviceName)) {
        [dict setObject:_deviceName forKey:@"device"];
    }
    if (CLLocationCoordinate2DIsValid(_coordinate)) {
        [dict setObject:[NSString stringWithFormat:@"%lf", _coordinate.latitude] forKey:@"lat"];
        [dict setObject:[NSString stringWithFormat:@"%lf", _coordinate.longitude] forKey:@"lng"];
    }
    
    return dict;
}

- (NSString *)createQuery
{
    return [self dynamicQuery];
}

@end
