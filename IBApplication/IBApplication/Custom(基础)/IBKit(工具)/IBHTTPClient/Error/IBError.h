//
//  IBError.h
//  IBApplication
//
//  Created by Bowen on 2019/6/30.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBErrorCode.h"

NS_ASSUME_NONNULL_BEGIN

@interface IBError : NSObject

@property (nonatomic, assign) IBErrorCode errorCode;
@property (nonatomic,   copy) NSString *errorMsg;

+ (IBError *)errorWithResponse:(NSDictionary *)response;
+ (IBError *)errorWithCode:(IBErrorCode)code msg:(NSString *)errorMsg;

@end

NS_ASSUME_NONNULL_END
