//
//  NSNetworkStatus.h
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kNSReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, NSNetworkModeStatus) {
    NSNotReachable,
    NSReachableViaWiFi,
    NSReachableViaWWAN
};

@interface NSNetworkStatus : NSObject

+ (instancetype)shareNetworkStatus;
/**
 当前网络状态
 */
- (NSNetworkModeStatus)currentNetworkStatus;
/**
 是否有网
 */
- (BOOL)isReachable;
/**
 具体的网络信息
 
 @return @"UnKnow" @"Wifi" @"NotReachable" @"2G" @"3G" @"4G"
 */
- (NSString *)specificNetworkMode;

@end
