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
 * 预加载产品列表
 */
- (void)prepareAppleProductList:(NSArray<MBPayProduct *> *)products;

/**
 * 发起支付 消耗品、订阅都由type判断
 */
- (void)createPaymentWithProduct:(MBPayRequest *)request payDelegate:(id<MBPayDelegate>)delegate;

/**
 * 退出登录等事件 暂停未完成支付的重试
 */
- (void)stopRetry;

/**
 * 恢复购买，会通知历史所有订单购买成功
 */
- (void)restoreIAP;

/**
 * 启动把本地的订阅订单上报一次，触发一下服务的续订逻辑
 */
- (void)checkLocalSubscribeOrder;

/**
* 登录等事件 检查已购项目上报服务核算
*/
- (void)checkCachedApplePay;

@end
