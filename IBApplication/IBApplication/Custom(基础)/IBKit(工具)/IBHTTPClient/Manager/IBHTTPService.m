//
//  IBHTTPService.m
//  IBApplication
//
//  Created by Bowen on 2019/12/10.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBHTTPService.h"
#import "AFNetworking.h"

@interface IBHTTPService ()


@end

@implementation IBHTTPService

+ (instancetype)sharedInstance
{
    static IBHTTPService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[[self class] alloc] init];
    });
    return service;
}

+ (void)GET:(NSString *)url params:(NSDictionary *)params completion:(IBHTTPCompletion)completion
{
    
}


@end
