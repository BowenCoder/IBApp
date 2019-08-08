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
@synthesize body;
@synthesize params;
@synthesize cacheTime;
@synthesize cacheType;
@synthesize retryTimes;
@synthesize retryInterval;
@synthesize timeoutInterval;
@synthesize requestType;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cacheTime = 0;
        self.cacheType = IBHttpCacheTypeNone;
        self.retryTimes = 0;
        self.retryInterval = 5;
        self.timeoutInterval = 10;
        self.isAllowAtom = YES;
    }
    return self;
}

- (NSDictionary*)requestHeaders {
    // 加密字段
    NSDictionary *dict = [[IBSecurity sharedInstance] securityHeadersWithUri:self.url];
    return dict;
}

- (void)appendAtomParams
{
    if (self.isAllowAtom) {
        self.url = [[IBAtomFactory sharedInstance] appendAtomParams:self.url];
    }
}

- (void)encryptUrl
{
    // 加密url
}

@end
