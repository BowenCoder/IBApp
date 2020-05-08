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

+ (void)deleteOrder:(MBPayOrderItem *)order;

+ (MBPayOrderItem *)orderWithProductId:(NSString *)productId;

+ (BOOL)hasOneOrderWithProductId:(NSString *)productId uid:(NSString *)uid;

+ (NSArray <MBPayOrderItem *>*)allSubscribeOrders;

+ (NSArray <MBPayOrderItem *>*)allOrders;

@end
