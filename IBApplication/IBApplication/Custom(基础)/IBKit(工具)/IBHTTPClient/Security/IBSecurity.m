//
//  IBSecurity.m
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBSecurity.h"

@implementation IBSecurity

+ (instancetype)sharedInstance
{
    static IBSecurity *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[IBSecurity alloc] init];
    });
    return instance;
}

- (NSDictionary *)securityHeadersWithUri:(NSString *)uri
{
    return nil;
}

- (void)start
{
    
}

- (void)clear
{
    
}

@end
