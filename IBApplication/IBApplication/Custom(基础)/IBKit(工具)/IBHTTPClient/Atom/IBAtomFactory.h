//
//  IBAtomFactory.h
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBAtomInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface IBAtomFactory : NSObject

@property (nonatomic, readonly, copy) NSDictionary *atomDict;

+ (instancetype)sharedInstance;

/**
 更新原子参数
 */
- (void)updateSmid:(NSString *)smid;

- (void)updateLogId:(NSString *)logId;

- (void)updateUserId:(NSString *)userId;

- (void)updateSessionId:(NSString *)sessionId;

- (void)updateCoordinate:(CLLocationCoordinate2D)coord;

/**
 往url后附加Atom参数
 */
- (NSString *)appendAtomInfo:(NSString *)url;
/**
 清除
 */
- (void)clear;

@end

NS_ASSUME_NONNULL_END
