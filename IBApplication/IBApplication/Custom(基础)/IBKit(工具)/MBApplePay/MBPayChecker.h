//
//  MBPayChecker.h
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBPayCheckerProtocol.h"

/*
 每一个订单一个校验实例，防止多份购买没到账
 */
@interface MBPayChecker : NSObject <MBPayCheckerProtocol>

@property (nonatomic, strong) MBPayProduct *product;
@property (nonatomic, copy) void(^checkErrorBlock)(MBPAYERROR type);
@property (nonatomic, copy) void(^checkSuccessBlock)(NSString *orderId);
@property (nonatomic, copy) void(^deleteOrderBlock)(id<MBPayCheckerProtocol> checker);

+ (void)checkLocalSubscribeOrder:(MBPayOrderItem *)orderItem;

@end
