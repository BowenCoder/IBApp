//
//  IBHTTPManagerProtocol.h
//  IBApplication
//
//  Created by BowenCoder on 2019/7/7.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBErrorCode.h"
#import "IBRequestProtocol.h"
#import "IBResponseProtocol.h"

typedef NS_ENUM(NSInteger, IBRequestType)  {
    IBRequestTypeGet = 0,
    IBRequestTypePostJson,
    IBRequestTypePostBinary
};

typedef NS_ENUM(NSInteger , IBRequestPriority) {
    IBRequestPriorityLow = -1,
    IBRequestPriorityDefault = 0,
    IBRequestPriorityHigh = 1,
};

NS_ASSUME_NONNULL_BEGIN

typedef void (^IBResponseBlock)(id<IBResponseProtocol>response);
typedef void (^IBHTTPResponseBlock)(IBErrorCode errorCode, NSString *errorMsg, NSDictionary *response);

@protocol IBHTTPManagerProtocol <NSObject>

- (void)get:(id<IBRequestProtocol>)request completion:(IBResponseBlock)completion;

- (void)get:(id<IBRequestProtocol>)request response:(id<IBResponseProtocol>)response completion:(IBResponseBlock)completion;

- (void)postJson:(id<IBPostJsonRequestProtocol>)request completion:(IBResponseBlock)completion;

- (void)postJson:(id<IBPostJsonRequestProtocol>)request response:(id<IBResponseProtocol>)response completion:(IBResponseBlock)completion;

- (void)postBinary:(id<IBPostBinaryRequestProtocol>)request completion:(IBResponseBlock)completion;

- (void)postBinary:(id<IBPostBinaryRequestProtocol>)request response:(id<IBResponseProtocol>)response completion:(IBResponseBlock)completion;

@end

NS_ASSUME_NONNULL_END
