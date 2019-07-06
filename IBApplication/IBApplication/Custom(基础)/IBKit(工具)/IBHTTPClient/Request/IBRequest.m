//
//  IBRequest.m
//  IBApplication
//
//  Created by BowenCoder on 2019/7/7.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBRequest.h"
#import "IBHelper.h"
#import "IBSecurity.h"
#import "IBAtomFactory.h"

@implementation IBRequest
@synthesize url;
@synthesize params;
@synthesize cacheTime;
@synthesize cacheType;
@synthesize retryTimes;
@synthesize retryInterval;
@synthesize timeoutInterval;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cacheTime = 0;
        self.cacheType = IBHttpCacheTypeNone;
        self.retryTimes = 0;
        self.retryInterval = 5;
        self.timeoutInterval = 10;
    }
    return self;
}

- (NSDictionary*)requestHeaders {
    // 加密字段
    NSDictionary *dict = [[IBSecurity sharedInstance] securityHeadersWithUri:self.url];
    return dict;
}

- (void)appendAtomicInfo
{
    self.url = [[IBAtomFactory sharedInstance] appendAtomParams:self.url];
}

- (void)encryptUrl
{
    // 加密url
}

@end

@implementation IBGetRequest

@end

@implementation IBPostJsonRequest
@synthesize body;

@end

@implementation IBPostBinaryRequest
@synthesize body;

@end

