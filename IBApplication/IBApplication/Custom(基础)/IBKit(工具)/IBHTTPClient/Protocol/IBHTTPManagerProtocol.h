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

typedef void (^IBResponseBlock)(id<IBResponseProtocol> response);
typedef void (^IBHttpResponseBlock)(IBErrorCode errorCode, NSString *errorMsg, NSDictionary *response);


NS_ASSUME_NONNULL_BEGIN

@protocol IBHTTPManagerProtocol <NSObject>

- (void)GET:(id<IBRequestProtocol>)request completion:(IBResponseBlock)completion;

- (void)GET:(id<IBRequestProtocol>)request responseProto:(id<IBResponseProtocol>)responseProto completion:(IBResponseBlock)completion;

- (void)PostJson:(id<IBPostJsonRequestProtocol>)request completion:(IBResponseBlock)completion;

- (void)PostJson:(id<IBPostJsonRequestProtocol>)request responseProto:(id<IBResponseProtocol>)responseProto completion:(IBResponseBlock)completion;

- (void)PostBinary:(id<IBPostBinaryRequestProtocol>)request completion:(IKResponseBlock)completion;

- (void)PostBinary:(id<IBPostBinaryRequestProtocol>)request responseProto:(id<IBResponseProtocol>)responseProto completion:(IBResponseBlock)completion;

@end

NS_ASSUME_NONNULL_END
