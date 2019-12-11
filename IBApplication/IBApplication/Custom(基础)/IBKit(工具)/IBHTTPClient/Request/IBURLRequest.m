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
    self.retryTimes = 0.0;
    self.retryInterval = 0.0;
    self.timeoutInterval = 10;
    self.isAllowAtom = YES;
    self.response = [[IBURLResponse alloc] init];
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

- (void)encryptUrl
{
    // 加密url
}

- (void)clearHandler
{
    self.completionHandler = nil;
    self.uploadProgressHandler = nil;
    self.downloadProgressHandler = nil;
}

- (NSString *)sendUrl {
    NSString *url = self.url;
    if (![self.url hasPrefix:@"http://"] && ![self.url hasPrefix:@"https://"]) {
        url = [NSString stringWithFormat:@"%@/%@", [self baseUrl], self.url];
    }
    if (self.isAllowAtom) {
        url = [[IBAtomFactory sharedInstance] appendAtomParams:self.url];
    }
    return url;
}

- (NSString *)description {
    if (self.method == IBHTTPPOST) {
        return [NSString stringWithFormat:@"#网络请求# <%@: %p> {URL: %@} {method: %ld} {body: %@}",NSStringFromClass([self class]), self, [self sendUrl], (long)self.method, self.body];
    } else {
        return [NSString stringWithFormat:@"#网络请求# <%@: %p> {URL: %@} {method: %ld}",NSStringFromClass([self class]), self, [self sendUrl], (long)self.method];
    }
}

@end
