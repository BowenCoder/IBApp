//
//  IBResponse.m
//  IBApplication
//
//  Created by BowenCoder on 2019/7/6.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBResponse.h"
#import "IBMacros.h"
#import "IBSerialization.h"

@implementation IBResponse
@synthesize data, dict, errorCode, errorMsg, task;

+ (instancetype)response
{
    return [[IBResponse alloc] init];
}

- (void)parseResponse
{
    if (kIsEmptyData(data)) {
        return;
    }
    self.dict = [IBSerialization unSerializeWithJsonData:self.data error:nil];
    if (kIsEmptyDict(self.dict)) {
        self.errorCode = [[self.dict objectForKey:@"error_code"] integerValue];
        self.errorMsg  = [self.dict objectForKey:@"error_msg"];
    }
}

@end
