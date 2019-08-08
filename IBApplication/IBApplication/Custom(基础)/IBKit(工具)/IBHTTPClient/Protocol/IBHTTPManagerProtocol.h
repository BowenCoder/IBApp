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

NS_ASSUME_NONNULL_BEGIN

typedef void (^IBResponseBlock)(id<IBResponseProtocol> response);
typedef void (^IBHTTPCompletionBlock)(IBErrorCode errorCode, NSString *errorMsg, NSDictionary *responseDict);

@protocol IBHTTPManagerProtocol <NSObject>

- (void)GET:(id<IBRequestProtocol>)request completion:(IBResponseBlock)completion;

- (void)GET:(id<IBRequestProtocol>)request response:(id<IBResponseProtocol>)response completion:(IBResponseBlock)completion;

- (void)POST:(id<IBRequestProtocol>)request completion:(IBResponseBlock)completion;

- (void)POST:(id<IBRequestProtocol>)request response:(id<IBResponseProtocol>)response completion:(IBResponseBlock)completion;

@end

NS_ASSUME_NONNULL_END
