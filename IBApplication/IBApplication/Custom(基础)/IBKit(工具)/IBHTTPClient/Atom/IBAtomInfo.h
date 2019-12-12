//
//  IBAtomInfo.h
//  IBApplication
//
//  Created by Bowen on 2019/12/12.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IBAtomInfo : NSObject

#pragma mark - 自动获取

@property (nonatomic, readonly, copy) NSString *idfa;
@property (nonatomic, readonly, copy) NSString *idfv;
@property (nonatomic, readonly, copy) NSString *proto;
@property (nonatomic, readonly, copy) NSString *license;
@property (nonatomic, readonly, copy) NSString *channel;
@property (nonatomic, readonly, copy) NSString *userAgent;
@property (nonatomic, readonly, copy) NSString *osVersion;
@property (nonatomic, readonly, copy) NSString *clientVersion;
@property (nonatomic, readonly, copy) NSString *deviceName;

@property (nonatomic, readonly, copy) NSString *networkMode; // 网络类型

#pragma mark - 手动设置

@property (nonatomic, copy) NSString *smid;
@property (nonatomic, copy) NSString *logId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 原子参数字典
 */
- (NSDictionary *)atomDict;

- (NSString *)createQuery;

@end

NS_ASSUME_NONNULL_END
