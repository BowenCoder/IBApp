//
//  IBURLRequest.m
//  IBApplication
//
//  Created by Bowen on 2019/8/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBURLRequest.h"
#import "IBHelper.h"
#import "IBEncode.h"
#import "IBAtomFactory.h"
#import "IBNetApiKeyInner.h"

@interface IBURLRequest ()

@property (nonatomic, copy) NSString *requestKey;

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
}

- (NSString *)baseUrl
{
    return kNETBaseUrl;
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
        url = [[IBAtomFactory sharedInstance] appendAtomInfo:self.url];
    }
    return url;
}

- (NSString *)requestKey {
    if(!_requestKey){
        NSString *url = self.url;
        if (![self.url hasPrefix:@"http://"] && ![self.url hasPrefix:@"https://"]) {
            url = [NSString stringWithFormat:@"%@/%@", [self baseUrl], self.url];
        }
        NSString *fullUrl = [IBHelper fullURL:url params:self.params];
        if (self.method == IBHTTPPOST) {
            fullUrl = [IBHelper fullURL:url params:self.body];
        }
        _requestKey = [IBEncode md5WithString:fullUrl];
    }
    return _requestKey;
}

- (NSString *)cacheKey {
    if(!_requestKey){
        NSString *url = self.url;
        if (![self.url hasPrefix:@"http://"] && ![self.url hasPrefix:@"https://"]) {
            url = [NSString stringWithFormat:@"%@/%@", [self baseUrl], self.url];
        }
        _requestKey = [IBEncode md5WithString:url];
    }
    return _requestKey;
}


- (NSString *)description {
    if (self.method == IBHTTPPOST) {
        return [NSString stringWithFormat:@"#network# {URL: %@} {method: %ld} {body: %@}", [self sendUrl], (long)self.method, self.body];
    } else {
        return [NSString stringWithFormat:@"#network# {URL: %@} {method: %ld}", [self sendUrl], (long)self.method];
    }
}

@end
