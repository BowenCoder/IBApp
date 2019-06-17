//
//  IBAtomFactory.h
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IBAtomInfo : NSObject

#pragma mark - 自动获取

@property (copy, readonly, nonatomic) NSString *idfa;
@property (copy, readonly, nonatomic) NSString *idfv;

@property (copy, readonly, nonatomic) NSString *proto;
@property (copy, readonly, nonatomic) NSString *license;
@property (copy, readonly, nonatomic) NSString *channel;
@property (copy, readonly, nonatomic) NSString *userAgent;
@property (copy, readonly, nonatomic) NSString *systemVersion;
@property (copy, readonly, nonatomic) NSString *clientVersion;

@property (atomic, copy) NSString *networkMode; // 网络类型

#pragma mark - 手动设置

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end


@interface IBAtomFactory : NSObject

@property (nonatomic, readonly, copy) NSDictionary *atomDict;

+ (instancetype)sharedInstance;

/**
 更新原子参数
 */
- (void)updateCoordinate:(CLLocationCoordinate2D)coord;
- (void)updateUserId:(NSString *)userId sessionId:(NSString *)sessionId;

/**
 往url后附加Atom参数
 */
- (NSString *)appendAtomParams:(NSString *)url;

/**
 服务入口地址
 */
- (NSString *)enterUrl;

/**
 服务入口备份
 */
- (NSString *)backupEnterUrl;

/**
 清除
 */
- (void)clear;

@end

NS_ASSUME_NONNULL_END
