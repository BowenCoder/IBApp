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
    self.dict = [IBSerialization unSerializeWithJsonData:self.data error:nil];
    if (kIsEmptyDict(self.dict)) {
        self.code = IBURLErrorContent;
        self.message = @"服务返回数据错误";
    } else {
        self.code = [[self.dict objectForKey:@"error_code"] integerValue];
        self.message = [self.dict objectForKey:@"error_msg"];
    }
}

@end
