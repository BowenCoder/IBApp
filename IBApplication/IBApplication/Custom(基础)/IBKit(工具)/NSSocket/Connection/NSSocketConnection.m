//
//  NSSocketConnection.m
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSSocketConnection.h"
#import "GCDAsyncSocket.h"

@interface NSSocketConnection () <GCDAsyncSocketDelegate>

/** 第三方socket */
@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
/** socket队列 */
@property (nonatomic, strong) dispatch_queue_t socketQueue;

@end

static void *isOnSocketQueueOrTargetQueueKey;
char * const NSSocketQueueLabel = "com.socketQueue.NSSocketQueueLabel";
static const NSUInteger TimeOut = -1;

@implementation NSSocketConnection

- (void)dealloc {
    
    NSLog(@" %@ - dealloc" ,NSStringFromClass([self class]));
}

- (instancetype)initWithConnectConfig:(NSSocketConfig *)connectConfig {
    
    if (self = [super init]) {
        
        NSAssert(connectConfig.host.length > 0, @"host is nil");
        NSAssert(connectConfig.port > 0, @"port is 0");
        
        _connectConfig = connectConfig;
        _socketQueue = dispatch_queue_create(NSSocketQueueLabel, DISPATCH_QUEUE_SERIAL);
        isOnSocketQueueOrTargetQueueKey = &isOnSocketQueueOrTargetQueueKey;
        dispatch_queue_set_specific(_socketQueue, isOnSocketQueueOrTargetQueueKey, (__bridge void *)self, NULL);
    }
    return self;
}

#pragma mark - queue

- (BOOL)isOnSocketQueue {
    
    return dispatch_get_specific(isOnSocketQueueOrTargetQueueKey) != NULL;
}

- (void)dispatchOnSocketQueue:(dispatch_block_t)block async:(BOOL)async {
    
    if ([self isOnSocketQueue]) {
        @autoreleasepool {
            block();
        }
        return;
    }
    if (async) {
        dispatch_async([self socketQueue], ^{
            @autoreleasepool {
                block();
            }
        });
        return;
    }
    dispatch_sync([self socketQueue], ^{
        @autoreleasepool {
            block();
        }
    });
}

#pragma mark - NSSocketDelegate

- (void)contect {
    
    if ([self isConnected]) return;
    @weakify(self)
    [self dispatchOnSocketQueue:^{
        @strongify(self)
        [self disconnect];
        
        self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketQueue];
        [self.asyncSocket setIPv4PreferredOverIPv6:NO];
        
        NSError *error = nil;
        [self.asyncSocket connectToHost:self.connectConfig.host onPort:self.connectConfig.port withTimeout:self.connectConfig.timeout error:&error];
        if (error) {
            [self didDisconnect:self withError:error];
        }
    } async:YES];
}

// 异步
- (void)disconnect {
    
    @weakify(self)
    [self dispatchOnSocketQueue:^{
        @strongify(self)
        if (NULL == self.asyncSocket) return;
        [self.asyncSocket disconnect];
        self.asyncSocket.delegate = nil;
        self.asyncSocket = nil;
    } async:YES];
}

- (BOOL)isConnected {
    
    __block BOOL result = NO;
    __weak typeof(self) weakSelf = self;
    [self dispatchOnSocketQueue:^{
        result = [weakSelf.asyncSocket isConnected];
    } async:NO];
    return result;
}

- (void)didConnect:(id<NSSocketDelegate>)delegate toHost:(NSString *)host port:(uint16_t)port {
    
}

- (void)didDisconnect:(id<NSSocketDelegate>)delegate withError:(NSError *)err {
    
}

- (void)didRead:(id<NSSocketDelegate>)delegate withData:(NSData *)data tag:(long)tag {
    
}

- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout {
    
    @weakify(self)
    [self dispatchOnSocketQueue:^{
        @strongify(self)
        [self.asyncSocket writeData:data withTimeout:timeout tag:10086];
    } async:YES];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
    NSLog(@"socket连接成功");
    [self didConnect:self toHost:host port:port];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    
    NSLog(@"socket连接失败...error: %@", err.description);
    [self didDisconnect:self withError:err];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSLog(@"socket收到数据...length: %lu, tag: %ld", (unsigned long)data.length, tag);
    [self didRead:self withData:data tag:tag];
    [sock readDataWithTimeout:TimeOut tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    NSLog(@"socket写入数据...Tag: %ld", tag);
    [sock readDataWithTimeout:TimeOut tag:tag];
}


@end
