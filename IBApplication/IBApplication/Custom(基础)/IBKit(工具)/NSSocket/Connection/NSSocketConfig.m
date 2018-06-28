//
//  NSSocketConfig.m
//  IBApplication
//
//  Created by Bowen on 2018/6/28.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSSocketConfig.h"

@implementation NSSocketConfig

- (instancetype)init {
    
    if (self = [super init]) {
        _host = nil;
        _port = 0;
        _imToken = nil;
        _timeout = 15;
        _heartbeatEnabled = YES;
        _heartbeatInterval = 30;
        _autoReconnect = YES;
        _connectMaxCount = 100;
        _connectInterval = 5;
    }
    return self;
}

@end
