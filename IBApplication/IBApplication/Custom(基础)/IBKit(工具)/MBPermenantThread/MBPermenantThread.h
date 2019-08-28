//
//  MBPermenantThread.h
//  IBApplication
//
//  Created by BowenCoder on 2019/8/29.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0))
@interface MBPermenantThread : NSObject

/**
 开启线程
 */
- (void)run;

/**
 结束线程
 */
- (void)stop;

/**
 在当前子线程执行一个任务
 */
- (void)executeTask:(dispatch_block_t)task;

@end

NS_ASSUME_NONNULL_END
