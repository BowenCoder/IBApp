//
//  IBNetworkStatus.h
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworkReachabilityManager.h"

extern NSString * const kIBReachabilityChangedNotification; // 通知监听网络状态变化

typedef NS_ENUM(NSInteger, IBNetworkModeStatus) {
    IBNetworkStatusUnknown              = -1, //程序刚启动，状态未知
    IBNetworkStatusNotReachable         = 0,
    IBNetworkStatusReachableViaWiFi     = 1,
    IBNetworkStatusReachableViaWWAN     = 2,
};

@interface IBNetworkStatus : NSObject

@property (nonatomic, readonly, assign) BOOL reachable;

@property (nonatomic, readonly, assign) BOOL reachableViaWWAN;

@property (nonatomic, readonly, assign) BOOL reachableViaWiFi;

+ (instancetype)shareInstance;

/**
 block监听网络状态的变化
 */
- (void)checkingNetworkStatus:(void(^)(IBNetworkModeStatus status))callback;

/**
 当前网络状态
 */
- (IBNetworkModeStatus)currentNetworkStatus;

/**
 具体的网络信息
 
 @return @"UnKnown" @"Wifi" @"NotReachable" @"2G" @"3G" @"4G"
 */
- (NSString *)specificNetworkMode;

@end
