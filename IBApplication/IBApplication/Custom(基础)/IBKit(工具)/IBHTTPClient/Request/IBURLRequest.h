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
    IBHTTPNone   = 0,
    IBHTTPGET    = 1,
    IBHTTPPOST   = 2,
    IBHTTPPUT    = 3,
    IBHTTPHEAD   = 4,
    IBHTTPPATCH  = 5,
    IBHTTPDELETE = 6,
};

NS_ASSUME_NONNULL_BEGIN

typedef void (^IBProgressHandler)(NSProgress *progress);
typedef void (^IBCompletionHandler)(IBURLResponse *response);
typedef void (^IBHTTPCompletion)(IBURLErrorCode errorCode, IBURLResponse *response);

@interface IBURLRequest : NSObject

@property (nonatomic, copy) NSString *url;

@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic, strong) NSDictionary *body;

@property (nonatomic, assign) BOOL isAllowAtom;

@property (nonatomic, assign) IBHTTPMethod method;

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, assign) NSTimeInterval cacheTime;

@property (nonatomic, assign) CGFloat retryTimes;

@property (nonatomic, assign) CGFloat retryInterval;

@property (nonatomic, strong) NSArray *authHeaderFields; // 格式@[@"Username", @"Password"]

@property (nonatomic, strong) NSDictionary *headerFields;

@property (nonatomic, copy, nullable) IBCompletionHandler completionHandler;

@property (nonatomic, copy, nullable) IBProgressHandler downloadProgressHandler;

@property (nonatomic, copy, nullable) IBProgressHandler uploadProgressHandler;

- (BOOL)useCDN;

- (NSString *)baseUrl;

- (NSString *)cdnUrl;

- (NSString *)sendUrl;

- (NSString *)requestKey;

- (NSString *)cacheKey;

- (BOOL)allowsCellularAccess;

- (void)clearHandler;

@end

NS_ASSUME_NONNULL_END
