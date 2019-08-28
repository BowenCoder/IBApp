//
//  MBPermenantThread.m
//  IBApplication
//
//  Created by BowenCoder on 2019/8/29.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBPermenantThread.h"

@interface MBPermenantThread ()

@property (nonatomic, strong) NSThread *innerThread;
@property (nonatomic, assign) BOOL isStopped;

@end

@implementation MBPermenantThread

#pragma mark - public methods

- (instancetype)init
{
    if (self = [super init]) {
        
        self.isStopped = NO;
        
        __weak typeof(self) weakSelf = self;
        self.innerThread = [[NSThread alloc] initWithBlock:^{
            [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
            while (weakSelf && !weakSelf.isStopped) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }];
    }
    return self;
}

- (void)run
{
    if (!self.innerThread) return;

    [self.innerThread start];
}

- (void)executeTask:(dispatch_block_t)task
{
    if (!self.innerThread || !task) return;
    
    [self performSelector:@selector(__executeTask:) onThread:self.innerThread withObject:task waitUntilDone:NO];
}

- (void)stop
{
    if (!self.innerThread) return;
    
    [self performSelector:@selector(__stop) onThread:self.innerThread withObject:nil waitUntilDone:YES];
}

- (void)dealloc
{
    [self stop];
}

#pragma mark - private methods

- (void)__stop
{
    self.isStopped = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.innerThread = nil;
}

- (void)__executeTask:(dispatch_block_t)task
{
    task();
}


@end
