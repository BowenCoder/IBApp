//
//  MBTimerSchedule.m
//  IBApplication
//
//  Created by Bowen on 2019/12/12.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBTimerSchedule.h"
#import "MBTimer.h"
#import "IBMacros.h"

@interface MBTimerSchedule ()

@property (nonatomic, strong) MBTimer *timer;
@property (nonatomic, assign) NSUInteger timerCounter;
@property (nonatomic, strong) NSHashTable *schedules;

@end

@implementation MBTimerSchedule

+ (instancetype)defaultSchedule
{
    static MBTimerSchedule *schedule = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        schedule = [[MBTimerSchedule alloc] init];
    });
    return schedule;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.timerCounter = 0;
    self.schedules = [NSHashTable weakObjectsHashTable];
}

- (void)registerSchedule:(id<MBTimerScheduleProtocol>)schedule
{
    dispatch_main_sync_safe(^{
        [self.schedules addObject:schedule];
    });
    [self startSchedule];
}

- (void)unregisterSchedule:(id<MBTimerScheduleProtocol>)schedule
{
    dispatch_main_sync_safe(^{
        [self.schedules removeObject:schedule];
    });
}

- (void)startSchedule
{
    [self.timer start];
}

- (void)stopSchedule
{
    [self.timer destroy];
}

- (void)scheduledExcute
{
    if (!self.schedules.anyObject) {
        [self stopSchedule];
        return;
    }
    self.timerCounter++;
    for (id<MBTimerScheduleProtocol> schedule in self.schedules) {
        if ([schedule respondsToSelector:@selector(scheduledTrigged:)]) {
            [schedule scheduledTrigged:self.timerCounter];
        }
    }
}

- (MBTimer *)timer {
    if(!_timer){
        dispatch_queue_t queue = dispatch_queue_create("timer.schedule.center", DISPATCH_QUEUE_CONCURRENT);
        _timer = [[MBTimer alloc] initWithQueue:queue];
        [_timer event:^{
            [self scheduledExcute];
        } timeIntervalWithSecs:1.0];
    }
    return _timer;
}

@end
