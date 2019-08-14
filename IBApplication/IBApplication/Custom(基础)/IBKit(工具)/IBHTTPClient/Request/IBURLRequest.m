//
//  IBURLRequest.m
//  IBApplication
//
//  Created by Bowen on 2019/8/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBURLRequest.h"
#import "IBAtomFactory.h"

@interface IBURLRequest ()

@end

@implementation IBURLRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupData];
    }
    return self;
}

- (void)setupData
{
    self.cacheTime = 0;
    self.retryTimes = 0;
    self.timeoutInterval = 10;
    self.isAllowAtom = YES;
}

- (NSString *)baseUrl
{
    return @"";
}

- (NSString *)cdnUrl
{
    return @"";
}

- (BOOL)useCDN
{
    return NO;
}

- (BOOL)allowsCellularAccess
{
    return YES;
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

- (void)clearBlock
{
    self.uploadProgressBlock = nil;
    self.downloadProgressBlock = nil;
    self.successBlock = nil;
    self.failureBlock = nil;
}

- (NSString *)description {
    if (self.method == IBHTTPMethodPOST) {
        return [NSString stringWithFormat:@"#网络请求# <%@: %p> {URL: %@} {method: %d} {body: %@}",NSStringFromClass([self class]), self, self.url, self.method, self.body];
    } else {
        return [NSString stringWithFormat:@"#网络请求# <%@: %p> {URL: %@} {method: %d}",NSStringFromClass([self class]), self, self.url, self.method];
    }
}

@end
