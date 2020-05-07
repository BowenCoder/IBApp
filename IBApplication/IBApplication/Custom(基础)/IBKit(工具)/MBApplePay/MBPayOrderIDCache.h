//
//  MBPayOrderIDCache.h
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBPayOrderItem.h"

@interface MBPayOrderIDCache : NSObject

+ (void)addOrder:(MBPayOrderItem *)order;

//支付成功后存储订阅订单，之后的自动续订使用
+ (void)saveSubScribeOrder:(MBPayOrderItem *)order;

+ (void)deleteOrder:(MBPayOrderItem *)order;

+ (NSArray <MBPayOrderItem *>*)subscribeOrdersWithProductId:(NSString *)productId;

+ (NSArray <MBPayOrderItem *>*)ordersWithProductId:(NSString *)productId;

+ (BOOL)hasOneOrderWithProductId:(NSString *)productId uid:(NSString *)uid;

+ (NSArray <MBPayOrderItem *>*)allSubscribeOrders;

@end
