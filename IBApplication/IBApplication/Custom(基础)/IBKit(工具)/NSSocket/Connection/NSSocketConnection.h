//
//  NSSocketConnection.h
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSSocketDelegate.h"
#import "NSSocketConfig.h"

/**
 *  socket网络连接对象，只负责socket网络的连接通信，内部使用GCDAsyncSocket。
 *  1-只公开GCDAsyncSocket的主要方法，增加使用的便捷性。
 *  2-封装的另一个目的是，易于后续更新调整。如果不想使用GCDAsyncSocket，只想修改内部实现即可，对外不产生影响。
 */
@interface NSSocketConnection : NSObject <NSSocketDelegate>

@property (nonatomic, strong) NSSocketConfig *connectConfig;

- (instancetype)initWithConnectConfig:(NSSocketConfig *)connectConfig;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (void)dispatchOnSocketQueue:(dispatch_block_t)block async:(BOOL)async;


@end
