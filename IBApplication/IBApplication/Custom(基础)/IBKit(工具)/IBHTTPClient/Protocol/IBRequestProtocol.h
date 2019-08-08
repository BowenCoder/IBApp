//
//  IBRequestProtocol.h
//  IBApplication
//
//  Created by BowenCoder on 2019/7/7.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IBRequestType)  {
    IBRequestTypeNone = 0,
    IBRequestTypeGet,
    IBRequestTypePost,
};

typedef NS_ENUM(NSInteger, IBHttpCacheType) {
    IBHttpCacheTypeNone = 0,
    IBHttpCacheTypeCache,
};

NS_ASSUME_NONNULL_BEGIN

@protocol IBRequestProtocol <NSObject>

@property (nonatomic, copy)   NSString        *url;
@property (nonatomic, strong) NSDictionary    *body;
@property (nonatomic, strong) NSDictionary    *params;
@property (nonatomic, assign) IBHttpCacheType cacheType;
@property (nonatomic, assign) NSTimeInterval  cacheTime;
@property (nonatomic, assign) NSInteger       retryTimes;
@property (nonatomic, assign) NSInteger       retryInterval;
@property (nonatomic, assign) NSTimeInterval  timeoutInterval;

@property (nonatomic, assign) BOOL isAllowAtom; // 需要原子参数
@property (nonatomic, assign) IBRequestType requestType;

@optional

/// 请求头
- (NSDictionary*)requestHeaders;

/// url拼接原子参数
- (void)appendAtomParams;

/// 加密url
- (void)encryptUrl;

@end

NS_ASSUME_NONNULL_END
