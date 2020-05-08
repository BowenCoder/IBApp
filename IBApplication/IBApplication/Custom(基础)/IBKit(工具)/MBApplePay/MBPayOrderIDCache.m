//
//  MBPayOrderIDCache.m
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import "MBPayOrderIDCache.h"
#import "YYCache.h"
#import "UICKeyChainStore.h"
#import "MBLogger.h"
#import "IBMacros.h"

#define MBPayKeyChainStoreServiceKey @"com.bowen.pay.service"

@implementation MBPayOrderIDCache

+ (void)addOrder:(MBPayOrderItem *)order
{
    if (!order) {
        return;
    }
    
    NSString *itemKey = NSStringNONil(order.productId);
    NSString *itemValue = NSStringNONil([order modelString]);
    
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:MBPayKeyChainStoreServiceKey];
    [store setString:itemValue forKey:itemKey];
}

+ (void)deleteOrder:(MBPayOrderItem *)order
{
    if (!order) {
        return;
    }
    
    NSString *itemKey = NSStringNONil(order.productId);
    
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:MBPayKeyChainStoreServiceKey];
    [store removeItemForKey:itemKey];
}

+ (MBPayOrderItem *)orderWithProductId:(NSString *)productId
{
    NSString *service = MBPayKeyChainStoreServiceKey;
    
    NSString *itemKey = NSStringNONil(productId);
    
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:service];
    NSString *string = [store stringForKey:itemKey];
    MBPayOrderItem *item = [MBPayOrderItem createFromString:string];
    
    return item;
}

+ (NSArray <MBPayOrderItem *>*)allSubscribeOrders
{
    NSString *service = MBPayKeyChainStoreServiceKey;

    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:service];

    NSArray *allKeys = [store allKeys];

    NSMutableArray *orders = [NSMutableArray array];

    for (NSString *itemKey in allKeys) {
        NSString *string = [store stringForKey:itemKey];
        MBPayOrderItem *item = [MBPayOrderItem createFromString:string];
        if (item.productType != MBPayProductType_ConsumableItem) {
            [orders addObject:item];
        }
    }
    return orders;
}

+ (NSArray <MBPayOrderItem *>*)allOrders
{
    NSString *service = MBPayKeyChainStoreServiceKey;
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:service];
    NSArray *allKeys = [store allKeys];
    NSMutableArray *orders = [NSMutableArray array];

    for (NSString *itemKey in allKeys) {
        NSString *string = [store stringForKey:itemKey];
        MBPayOrderItem *item = [MBPayOrderItem createFromString:string];
        [orders addObject:item];
    }
    
    return orders;
}

+ (BOOL)hasOneOrderWithProductId:(NSString *)productId uid:(NSString *)uid
{
    MBPayOrderItem *item = [self orderWithProductId:productId];
    
    MBLogI(@"#apple.pay# keychain orders %@ %@ %@",
           NSStringNONil(item.productId),
           NSStringNONil(item.uid),
           NSStringNONil(item.orderId));
    
    if ([item.uid isEqualToString:uid]) {
        return YES;
    }
    return NO;
}

@end
