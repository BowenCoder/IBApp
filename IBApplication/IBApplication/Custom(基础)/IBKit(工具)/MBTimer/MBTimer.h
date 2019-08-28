//
//  MBTimer.h
//  IBApplication
//
//  Created by BowenCoder on 2019/8/29.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBTimer : NSObject

@property (strong, readonly, nonatomic) dispatch_source_t dispatchSource;

+ (instancetype)timer;
- (instancetype)initWithQueue:(dispatch_queue_t)queue;

- (void)event:(dispatch_block_t)block timeInterval:(uint64_t)interval;
- (void)event:(dispatch_block_t)block timeInterval:(uint64_t)interval delay:(uint64_t)delay;
- (void)event:(dispatch_block_t)block cancelEvent:(dispatch_block_t)cancelEvent timeInterval:(uint64_t)interval delay:(uint64_t)delay;

- (void)event:(dispatch_block_t)block timeIntervalWithSecs:(float)secs;
- (void)event:(dispatch_block_t)block timeIntervalWithSecs:(float)secs delaySecs:(float)delaySecs;
- (void)event:(dispatch_block_t)block cancelEvent:(dispatch_block_t)cancelEvent timeIntervalWithSecs:(float)secs delaySecs:(float)delaySecs;

- (void)start;
- (void)destroy;


@end

NS_ASSUME_NONNULL_END
