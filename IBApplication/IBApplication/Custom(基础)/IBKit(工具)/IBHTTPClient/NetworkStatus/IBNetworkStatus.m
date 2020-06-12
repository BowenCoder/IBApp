//
//  IBNetworkStatus.m
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBNetworkStatus.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

NSString * const kIBReachabilityChangedNotification = @"kIBReachabilityChangedNotification";

@interface IBNetworkStatus ()

/**
 网络状态
 */
@property (nonatomic, strong) AFNetworkReachabilityManager *reachability;
/**
 2G数组
 */
@property (nonatomic,strong) NSArray *technology2GArray;
/**
 3G数组
 */
@property (nonatomic,strong) NSArray *technology3GArray;
/**
 4G数组
 */
@property (nonatomic,strong) NSArray *technology4GArray;
/**
 网络状态描述
 */
@property (nonatomic, strong) CTTelephonyNetworkInfo *networkInfo;

@end

@implementation IBNetworkStatus

- (void)dealloc {
    [self.reachability stopMonitoring];
}

+ (instancetype)shareInstance {
    
    static IBNetworkStatus *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[[self class] alloc] init];
        }
    });
    return instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        [self.reachability startMonitoring];
        [self addNetworkingStatusNotification];
    }
    return self;
}

- (void)addNetworkingStatusNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveReachabilityChangedNotification:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)receiveReachabilityChangedNotification:(NSNotification *)notification {
    NSNumber *net = notification.userInfo[AFNetworkingReachabilityNotificationStatusItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIBReachabilityChangedNotification object:net];
}

- (IBNetworkModeStatus)currentNetworkStatus {
    
    AFNetworkReachabilityStatus status = self.reachability.networkReachabilityStatus;
    switch (status) {
        case AFNetworkReachabilityStatusUnknown:
            return IBNetworkStatusUnknown;
            break;
        case AFNetworkReachabilityStatusNotReachable:
            return IBNetworkStatusNotReachable;
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return IBNetworkStatusReachableViaWWAN;
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return IBNetworkStatusReachableViaWiFi;
            break;
        default:
            return IBNetworkStatusUnknown;
    }
}

/**
 获取具体网络状态
 */
- (NSString *)specificNetworkMode
{
    IBNetworkModeStatus status = [self currentNetworkStatus];
    
    if (status == IBNetworkStatusNotReachable){
        return @"NotReachable";
    }
    if (status == IBNetworkStatusReachableViaWiFi) {
        return @"Wifi";
    }
    
    //获取当前网络描述
    NSString *currentStatus = self.networkInfo.currentRadioAccessTechnology;
    
    if ([self.technology2GArray containsObject:currentStatus]) {
        return @"2G";
    }
    else if ([self.technology3GArray containsObject:currentStatus]) {
        return @"3G";
    }
    else if ([self.technology4GArray containsObject:currentStatus]) {
        return @"4G";
    }
    return @"Unkown";
}

- (void)checkingNetworkStatus:(void(^)(IBNetworkModeStatus status))callback {
    
    [self.reachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusUnknown) {
            if (callback) callback(IBNetworkStatusUnknown);
        } else if (status == AFNetworkReachabilityStatusNotReachable){
            if (callback) callback(IBNetworkStatusNotReachable);
        } else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            if (callback) callback(IBNetworkStatusReachableViaWWAN);
        } else if (status == AFNetworkReachabilityStatusReachableViaWiFi){
            if (callback) callback(IBNetworkStatusReachableViaWiFi);
        }
    }];
}

#pragma mark - 懒加载

- (BOOL)reachable {
    return [self.reachability isReachableViaWWAN] || [self.reachability isReachableViaWiFi];
}

- (BOOL)reachableViaWWAN {
    return self.reachability.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN;
}

- (BOOL)reachableViaWiFi {
    return self.reachability.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi;
}

- (AFNetworkReachabilityManager *)reachability{
    if (!_reachability) {
        _reachability = [AFNetworkReachabilityManager sharedManager];
    }
    return _reachability;
}

- (CTTelephonyNetworkInfo *)networkInfo
{
    if (!_networkInfo) {
        _networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    }
    return _networkInfo;
}

/**
 2G识别数组
 */
- (NSArray *)technology2GArray{
    if(!_technology2GArray){
        _technology2GArray = @[CTRadioAccessTechnologyEdge,
                               CTRadioAccessTechnologyGPRS,
                               CTRadioAccessTechnologyEdge];
    }
    return _technology2GArray;
}

/**
 3G识别数组
 */
-(NSArray *)technology3GArray{
    if(!_technology3GArray){
        _technology3GArray = @[CTRadioAccessTechnologyHSDPA,
                               CTRadioAccessTechnologyWCDMA,
                               CTRadioAccessTechnologyHSUPA,
                               CTRadioAccessTechnologyCDMA1x,
                               CTRadioAccessTechnologyCDMAEVDORev0,
                               CTRadioAccessTechnologyCDMAEVDORevA,
                               CTRadioAccessTechnologyCDMAEVDORevB,
                               CTRadioAccessTechnologyeHRPD];
    }
    return _technology3GArray;
}

/**
 4G识别数组
 */
-(NSArray *)technology4GArray{
    if(!_technology4GArray){
        _technology4GArray = @[CTRadioAccessTechnologyLTE];
    }
    return _technology4GArray;
}

@end
