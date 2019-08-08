//
//  IBResponseProtocol.h
//  IBApplication
//
//  Created by BowenCoder on 2019/7/6.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBError.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IBResponseProtocol <NSObject>

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSDictionary *dict;
@property (nonatomic, copy)   NSString *errorMsg;
@property (nonatomic, assign) IBErrorCode errorCode;
@property (nonatomic, strong) NSURLSessionDataTask *task;

- (void)parseResponse;

@end

NS_ASSUME_NONNULL_END
