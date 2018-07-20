//
//  IBNetworkStatus.h
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kIBReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, IBNetworkModeStatus) {
    IBNotReachable,
    IBReachableViaWiFi,
    IBReachableViaWWAN
};

@interface IBNetworkStatus : NSObject

+ (instancetype)shareNetworkStatus;
/**
 当前网络状态
 */
- (IBNetworkModeStatus)currentNetworkStatus;
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
