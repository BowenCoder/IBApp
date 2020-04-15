//
//  MBTimerSchedule.h
//  IBApplication
//
//  Created by Bowen on 2019/12/12.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MBTimerScheduleProtocol <NSObject>

/// 1s异步调度一次
/// @param timerCounter 计数器
- (void)scheduledTrigged:(NSUInteger)timerCounter;

@end

/// 时间任务调度中心
@interface MBTimerSchedule : NSObject

/// 单例
+ (instancetype)defaultSchedule;

/// 注册任务
/// @param schedule 任务
- (void)registerSchedule:(id<MBTimerScheduleProtocol>)schedule;

/// 解除任务，不使用一定解除
/// @param schedule 任务
- (void)unregisterSchedule:(id<MBTimerScheduleProtocol>)schedule;

@end

// IKRoomScheduleModule
NS_ASSUME_NONNULL_END
