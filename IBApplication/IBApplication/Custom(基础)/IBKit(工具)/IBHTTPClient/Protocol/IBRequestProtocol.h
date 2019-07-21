//
//  IBRequestProtocol.h
//  IBApplication
//
//  Created by BowenCoder on 2019/7/7.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IBHttpCacheType) {
    IBHttpCacheTypeNone = 0,
    IBHttpCacheTypeCache,
};

NS_ASSUME_NONNULL_BEGIN

@protocol IBRequestProtocol <NSObject>

@property (nonatomic, copy)   NSString        *url;
@property (nonatomic, strong) NSDictionary    *params;
@property (nonatomic, assign) IBHttpCacheType cacheType;
@property (nonatomic, assign) NSTimeInterval  cacheTime;
@property (nonatomic, assign) NSInteger       retryTimes;
@property (nonatomic, assign) NSInteger       retryInterval;
@property (nonatomic, assign) NSTimeInterval  timeoutInterval;

@optional

/// 请求头
- (NSDictionary*)requestHeaders;

/// url拼接原子参数
- (void)appendAtomicInfo;

/// 加密url
- (void)encryptUrl;

@end

@protocol IBPostJsonRequestProtocol <IBRequestProtocol>

@optional

@property (nonatomic, strong) NSDictionary *body;

@end

@protocol IBPostBinaryRequestProtocol <IBRequestProtocol>

@optional

@property (nonatomic, strong) NSData *body;

@end

NS_ASSUME_NONNULL_END
