//
//  IBNetworkConfig.m
//  IBApplication
//
//  Created by Bowen on 2019/6/17.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBNetworkConfig.h"
#import "IBServiceInfoHandler.h"
#import "IBApp.h"

@implementation IBNetworkConfig

+ (NSString *)channelCode
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *channel = [infoDictionary valueForKeyPath:@"app.channel"];
    NSAssert(channel != nil && [channel isKindOfClass:[NSString class]],
             @"appconfig error");
    return channel;
}

+ (NSString *)licenseCode
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *license = [infoDictionary valueForKeyPath:@"app.license"];
    NSAssert(license != nil && [license isKindOfClass:[NSString class]],
             @"appconfig error");
    return license;
}

+ (NSString *)projectCode
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary valueForKeyPath:@"app.project"];
    NSAssert(version != nil && [version isKindOfClass:[NSString class]],
             @"appconfig error");
    return version;
}

+ (NSString *)protoVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary valueForKeyPath:@"app.proto"];
    NSAssert(version != nil && [version isKindOfClass:[NSString class]],
             @"appconfig error");
    return version;
}

+ (NSString *)clientVersion
{
    NSString *projectCode = [self projectCode];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *clientVersion = [NSString stringWithFormat:@"%@_v%@", projectCode, version];
    return clientVersion;
}

+ (NSString *)systemVersion
{
    return [NSString stringWithFormat:@"ios_%@", [[UIDevice currentDevice] systemVersion]];
}

+ (NSString *)iPhoneType
{
    return [IBApp machineModel];
}

+ (NSString *)deviceName
{
    return [UIDevice currentDevice].name;
}

+ (NSString *)idfa
{
    return [IBApp idfa];
}

+ (NSString *)idfv
{
    return [IBApp idfv];
}

+ (NSString *)wifiESSID
{
    return [[IBApp wifiSSID] objectForKey:@"SSID"];
}

+ (NSString *)wifiBSSID
{
    return [[IBApp wifiSSID] objectForKey:@"BSSID"];
}

+ (NSString *)enterUrl
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *url = [infoDictionary valueForKeyPath:@"serviceinfo.url"];
    NSAssert(url != nil && [url isKindOfClass:[NSString class]],
             @"appconfig error");
    return url;
}

+ (NSString *)backupUrl
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *url = [infoDictionary valueForKeyPath:@"serviceinfo.url_backup"];
    NSAssert(url != nil && [url isKindOfClass:[NSString class]],
             @"appconfig error");
    return url;
}

+ (NSDictionary *)serviceInfo
{
    NSString *serviceInfoPath = [[NSBundle mainBundle] pathForResource:@"serviceInfo" ofType:@"plist"];
    NSDictionary *info = [[NSDictionary alloc] initWithContentsOfFile:serviceInfoPath];
    return info;
}

@end
