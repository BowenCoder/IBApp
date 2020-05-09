//
//  MBPayManager.h
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBPayRequest.h"
#import "MBPayDelegate.h"

@interface MBPayManager : NSObject

+ (instancetype)sharedInstance;

/**
 * 初始化，登录完成之后调用
 */
- (void)setup;

/**
 * 预加载产品列表
 */
- (void)prepareAppleProductList:(NSArray<MBPayProduct *> *)products;

/**
 * 发起支付 消耗品、订阅都由type判断
 */
- (void)createPaymentWithProduct:(MBPayRequest *)request payDelegate:(id<MBPayDelegate>)delegate;

/**
 * 恢复购买，会通知历史所有订单购买成功
 */
- (void)restoreIAP;

@end
