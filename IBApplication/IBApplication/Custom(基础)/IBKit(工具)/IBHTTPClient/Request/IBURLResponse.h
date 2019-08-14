//
//  IBURLResponse.h
//  IBApplication
//
//  Created by Bowen on 2019/8/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBMacros.h"
#import "IBError.h"

NS_ASSUME_NONNULL_BEGIN

@interface IBURLResponse : NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSDictionary *dict;
@property (nonatomic, copy)   NSString *errorMsg;
@property (nonatomic, assign) IBErrorCode errorCode;
@property (nonatomic, strong) NSURLSessionTask *task;

+ (instancetype)response;

- (void)parseResponse;

@end

NS_ASSUME_NONNULL_END
