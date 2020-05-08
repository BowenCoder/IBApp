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

#define Lock() dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self.lock)

@interface MBTimerSchedule ()

@property (nonatomic, strong) MBTimer *timer;
@property (nonatomic, assign) NSUInteger timerCounter;
@property (nonatomic, strong) NSHashTable *schedules;
@property (nonatomic, strong) dispatch_semaphore_t lock;

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
    self.lock = dispatch_semaphore_create(1);
    self.schedules = [NSHashTable weakObjectsHashTable];
}

- (void)registerSchedule:(id<MBTimerScheduleProtocol>)schedule
{
    Lock();
    [self.schedules addObject:schedule];
    Unlock();
    [self startSchedule];
}

- (void)unregisterSchedule:(id<MBTimerScheduleProtocol>)schedule
{
    Lock();
    [self.schedules removeObject:schedule];
    Unlock();
}

- (void)startSchedule
{
    [self.timer start];
}

- (void)stopSchedule
{
    self.timerCounter = 0;
    [self.timer destroy];
}

- (void)scheduledExcute
{
    if (!self.schedules.anyObject) {
        [self stopSchedule];
        return;
    }
    Lock();
    NSArray *schedules = self.schedules.allObjects;
    Unlock();
    self.timerCounter++;
    for (id<MBTimerScheduleProtocol> schedule in schedules) {
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scheduledExcute];
            });
        } timeIntervalWithSecs:1.0];
    }
    return _timer;
}

@end
