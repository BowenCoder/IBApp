//
//  MBFilterLogger.m
//  IBApplication
//
//  Created by Bowen on 2019/5/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBFilterLogger.h"

@interface MBFilterLogger ()

@property (nonatomic, strong) NSMutableArray *filters;

@end

@implementation MBFilterLogger

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.filters = [NSMutableArray new];
    }
    
    return self;
}

- (void)addFilter:(id<MBLogFilterDelegate>)filter
{
    @synchronized (self)
    {
        [self.filters addObject:filter];
    }
}

- (void)removeFilter:(id<MBLogFilterDelegate>)filter
{
    @synchronized (self)
    {
        [self.filters removeObject:filter];
    }
}

- (void)logMessage:(DDLogMessage *)logMessage;
{
    NSString *message = _logFormatter ? [_logFormatter formatLogMessage:logMessage] : logMessage.message;
    if (message.length)
    {
        @synchronized (self)
        {
            for (id<MBLogFilterDelegate> filter in self.filters)
            {
                if ([filter respondsToSelector:@selector(onLogMessage:)])
                    [filter onLogMessage:message];
            }
        }
    }
}

@end
