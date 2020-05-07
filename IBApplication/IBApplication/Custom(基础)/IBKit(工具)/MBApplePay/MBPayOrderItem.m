//
//  MBPayOrderItem.m
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import "MBPayOrderItem.h"
#import "YYModel.h"

@implementation MBPayOrderItem

- (NSString *)modelString
{
    return [self yy_modelToJSONString];
}

+ (MBPayOrderItem *)createFromString:(NSString *)modelString
{
    return [MBPayOrderItem yy_modelWithJSON:modelString];
}

@end
