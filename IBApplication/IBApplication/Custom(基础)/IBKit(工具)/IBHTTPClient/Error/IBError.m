//
//  IBError.m
//  IBApplication
//
//  Created by Bowen on 2019/6/30.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBError.h"
#import "IBMacros.h"

@implementation IBError

+ (IBError *)errorWithResponse:(NSDictionary *)response
{
    IBError *error = [[IBError alloc] init];
    if (kIsEmptyDict(response)) {
        error.errorCode = IBOtherError;
        error.errorMsg  = @"未知错误";
    } else {
        error.errorCode = [[response objectForKey:@"error_code"] integerValue];
        error.errorMsg  = [response objectForKey:@"error_msg"];
    }
    return error;
}

+ (IBError *)errorWithCode:(IBErrorCode)code msg:(NSString *)errorMsg
{
    IBError *error = [[IBError alloc] init];
    error.errorCode =code;
    error.errorMsg = errorMsg;
    return error;
}

@end
