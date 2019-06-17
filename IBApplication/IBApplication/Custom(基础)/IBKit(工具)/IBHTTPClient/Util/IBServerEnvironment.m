//
//  IBServerEnvironment.m
//  IBApplication
//
//  Created by Bowen on 2019/5/24.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBServerEnvironment.h"

@interface IBServerEnvironment ()

@end

@implementation IBServerEnvironment

+ (instancetype)shareInstance
{
    static IBServerEnvironment *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

@end
