//
//  IBURLRequest.h
//  IBApplication
//
//  Created by Bowen on 2019/8/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBURLResponse.h"

typedef NS_ENUM(NSInteger, IBHTTPMethod) {
    IBHTTPMethodGET    = 0,
    IBHTTPMethodPOST   = 1,
    IBHTTPMethodPUT    = 2,
    IBHTTPMethodHEAD   = 3,
    IBHTTPMethodPATCH  = 4,
    IBHTTPMethodDELETE = 5,
};

typedef NS_ENUM(NSInteger, IBHTTPCacheType) {
    IBHTTPCacheTypeNone = 0,
    IBHTTPCacheTypeCache,
};

NS_ASSUME_NONNULL_BEGIN

typedef void (^IBProgressHandler)(NSProgress *progress);
typedef void (^IBCompletionHandler)(IBURLResponse *response);
typedef void (^IBHTTPCompletion)(IBErrorCode errorCode, NSString *errorMsg, NSDictionary *response);

@interface IBURLRequest : NSObject

@property (nonatomic, copy) NSString *url;

@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic, strong) NSDictionary *body;

@property (nonatomic, assign) IBHTTPMethod method;

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, assign) NSTimeInterval cacheTime;

@property (nonatomic, assign) NSInteger retryTimes;

@property (nonatomic, assign) BOOL isAllowAtom;

/// 格式@[@"Username", @"Password"]
@property (nonatomic, strong) NSArray *authHeaderFields;

@property (nonatomic, strong) NSDictionary *headerFields;

@property (nonatomic, strong) NSURLSessionTask *requestTask;

@property (nonatomic, strong) IBURLResponse *response;

@property (nonatomic, copy, nullable) IBCompletionHandler successHandler;

@property (nonatomic, copy, nullable) IBCompletionHandler failureHandler;

@property (nonatomic, copy, nullable) IBProgressHandler downloadProgressHandler;

@property (nonatomic, copy, nullable) IBProgressHandler uploadProgressHandler;

- (BOOL)useCDN;

- (NSString *)baseUrl;

- (NSString *)cdnUrl;

- (NSString *)sendUrl;

- (BOOL)allowsCellularAccess;

- (void)clearHandler;

@end

NS_ASSUME_NONNULL_END
