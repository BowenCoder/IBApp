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

typedef void (^IBProgressBlock)(NSProgress * _Nullable progress);
typedef void (^IBResponseBlock)(IBURLResponse * _Nullable response);

NS_ASSUME_NONNULL_BEGIN

@interface IBURLRequest : NSObject

@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) BOOL isAllowAtom;

@property (nonatomic, strong) NSDictionary *body;

@property (nonatomic, assign) IBHTTPMethod method;

@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, assign) NSTimeInterval cacheTime;

@property (nonatomic, assign) NSInteger retryTimes;

/// 格式@[@"Username", @"Password"]
@property (nonatomic, strong) NSArray *authHeaderFields;

@property (nonatomic, strong) NSDictionary *headerFields;

@property (nonatomic, strong) NSURLSessionTask *requestTask;

@property (nonatomic, strong) IBURLResponse *response;

@property (nonatomic, copy, nullable) IBResponseBlock successBlock;

@property (nonatomic, copy, nullable) IBResponseBlock failureBlock;

@property (nonatomic, copy, nullable) IBProgressBlock downloadProgressBlock;

@property (nonatomic, copy, nullable) IBProgressBlock uploadProgressBlock;

- (BOOL)useCDN;

- (NSString *)baseUrl;

- (NSString *)cdnUrl;

- (BOOL)allowsCellularAccess;

- (void)clearBlock;

@end

NS_ASSUME_NONNULL_END
