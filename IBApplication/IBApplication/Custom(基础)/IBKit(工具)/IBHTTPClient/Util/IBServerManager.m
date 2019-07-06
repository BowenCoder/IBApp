//
//  IBServerManager.m
//  IBApplication
//
//  Created by Bowen on 2019/7/1.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBServerManager.h"

@implementation IBServerManager

+ (instancetype)shareInstance
{
    static IBServerManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[IBServerManager alloc] init];
    });
    return manager;
}

/**
 开始刷新ServerInfo
 */
- (void)refreshServerInfo
{
    
}

/**
 停止刷新ServerInfo
 */
- (void)stopRefresh
{
    
}


@end
