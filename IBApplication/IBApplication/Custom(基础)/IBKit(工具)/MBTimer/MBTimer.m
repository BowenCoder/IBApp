//
//  MBTimer.m
//  IBApplication
//
//  Created by BowenCoder on 2019/8/29.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBTimer.h"

@interface MBTimer ()

@property (nonatomic, strong) dispatch_source_t dispatchSource;
@property (nonatomic, assign) BOOL isResuming;

@end

@implementation MBTimer

+ (instancetype)timer {
    return [[MBTimer alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        self.isResuming = NO;
        self.dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    }
    return self;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue {
    if (self = [super init]) {
        self.dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    }
    return self;
}

- (void)event:(dispatch_block_t)block timeInterval:(uint64_t)interval {
    NSParameterAssert(block);
    dispatch_source_set_timer(self.dispatchSource, dispatch_time(DISPATCH_TIME_NOW, 0), interval, 0);
    dispatch_source_set_event_handler(self.dispatchSource, block);
}

- (void)event:(dispatch_block_t)block timeInterval:(uint64_t)interval delay:(uint64_t)delay {
    NSParameterAssert(block);
    dispatch_source_set_timer(self.dispatchSource, dispatch_time(DISPATCH_TIME_NOW, delay), interval, 0);
    dispatch_source_set_event_handler(self.dispatchSource, block);
}

- (void)event:(dispatch_block_t)block cancelEvent:(dispatch_block_t)cancelEvent timeInterval:(uint64_t)interval delay:(uint64_t)delay {
    NSParameterAssert(block);
    dispatch_source_set_timer(self.dispatchSource, dispatch_time(DISPATCH_TIME_NOW, delay), interval, 0);
    dispatch_source_set_event_handler(self.dispatchSource, block);
    dispatch_source_set_cancel_handler(self.dispatchSource, cancelEvent);
}

- (void)event:(dispatch_block_t)block timeIntervalWithSecs:(float)secs {
    NSParameterAssert(block);
    dispatch_source_set_timer(self.dispatchSource, dispatch_time(DISPATCH_TIME_NOW, 0), secs * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.dispatchSource, block);
}

- (void)event:(dispatch_block_t)block timeIntervalWithSecs:(float)secs delaySecs:(float)delaySecs {
    NSParameterAssert(block);
    dispatch_source_set_timer(self.dispatchSource, dispatch_time(DISPATCH_TIME_NOW, delaySecs * NSEC_PER_SEC), secs * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.dispatchSource, block);
}

- (void)event:(dispatch_block_t)block cancelEvent:(dispatch_block_t)cancelEvent timeIntervalWithSecs:(float)secs delaySecs:(float)delaySecs {
    NSParameterAssert(block);
    dispatch_source_set_timer(self.dispatchSource, dispatch_time(DISPATCH_TIME_NOW, delaySecs * NSEC_PER_SEC), secs * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.dispatchSource, block);
    dispatch_source_set_cancel_handler(self.dispatchSource, cancelEvent);
}

- (void)start {
    if (self.isResuming) {
        return;
    }
    self.isResuming = YES;
    dispatch_resume(self.dispatchSource);
}

- (void)destroy {
    if (!self.isResuming) {
        return;
    }
    self.isResuming = NO;
    dispatch_source_cancel(self.dispatchSource);
}

@end
