//
//  IBURLResponse.m
//  IBApplication
//
//  Created by Bowen on 2019/8/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBURLResponse.h"
#import "IBSerialization.h"

@implementation IBURLResponse

+ (instancetype)response
{
    return [[IBURLResponse alloc] init];
}

- (void)parseResponse
{
    if (kIsEmptyData(self.data)) {
        return;
    }
    self.dict = [IBSerialization unSerializeWithJsonData:self.data error:nil];
    if (kIsEmptyDict(self.dict)) {
        self.errorCode = [[self.dict objectForKey:@"error_code"] integerValue];
        self.errorMsg  = [self.dict objectForKey:@"error_msg"];
    }
}

@end
