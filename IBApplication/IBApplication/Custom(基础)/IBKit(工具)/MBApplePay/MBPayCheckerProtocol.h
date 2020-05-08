//
//  MBPayCheckerProtocol.h
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#ifndef MBPayCheckerProtocol_h
#define MBPayCheckerProtocol_h

#import "MBPayDelegate.h"
#import <StoreKit/StoreKit.h>
#import "MBPayRequest.h"

/*
每一个订单一个校验实例，防止多份购买没到账
*/
@class MBPayOrderItem;
@protocol MBPayCheckerProtocol<NSObject>

@property (nonatomic, strong) MBPayProduct *product;
@property (nonatomic, copy) void(^checkErrorBlock)(MBPAYERROR type);
@property (nonatomic, copy) void(^checkSuccessBlock)(NSString *orderId);
@property (nonatomic, copy) void(^deleteCheckerBlock)(id<MBPayCheckerProtocol> checker);

/**
 * 支付成功上报服务
 */
- (void)checkReceiptWithOrderItem:(MBPayOrderItem *)orderItem;

/**
 * 检查未完成订单
 */
+ (void)checkUnFinishedOrder;

/**
 * 退出登录时，停止重试上报
 */
- (void)stopRetry;

@end

#endif /* MBPayCheckerProtocol_h */
