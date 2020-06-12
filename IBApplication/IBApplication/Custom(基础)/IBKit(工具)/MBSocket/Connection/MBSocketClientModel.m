//
//  MBSocketClientModel.m
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketClientModel.h"

@implementation MBSocketClientModel

- (instancetype)init
{
    if (self = [super init]) {
        self.host = @"";
        self.port = 0;
        self.connectTimeout = 15;
        self.heartbeatInterval = 30;
        self.messageTimeout = 30;
        self.retryConnectMaxCount = 100;
        self.retryConnectInterval = 5;
    }
    return self;
}

@end
