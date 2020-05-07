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

@implementation MBPayOrderIDCache

#define MBPayKeyChainStoreServiceKey @"com.bowen.pay.service"
#define MBPaySubscribeKeyChainStoreServiceKey @"com.bowen.subscribe.service"
#define MBPayKeyChainStoreValueSeparateKey @"\n"

+ (void)addOrder:(MBPayOrderItem *)order
{
    if (!order) {
        return;
    }
    NSString *service = MBPayKeyChainStoreServiceKey;
    
    NSString *itemKey = NSStringNONil(order.productId);
    NSString *itemValue = NSStringNONil([order modelString]);
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:service];
    NSString *string = [store stringForKey:itemKey];
    NSArray *arr = [string componentsSeparatedByString:MBPayKeyChainStoreValueSeparateKey];
    NSMutableArray *muArr = [NSMutableArray arrayWithArray:arr];
    [muArr addObject:itemValue];
    
    if (muArr.count > 10) {
        [muArr removeObjectAtIndex:0];
    }
    
    NSString *result = [muArr componentsJoinedByString:MBPayKeyChainStoreValueSeparateKey];
    
    [store setString:result forKey:itemKey];
}

+ (void)saveSubScribeOrder:(MBPayOrderItem *)order
{
    if (!order) {
        return;
    }
    
    if (order.productType != MBPayProductType_AutoRenewSubscription) {
        return;
    }
    
    order.createTime = time(NULL);
    NSString *service = MBPaySubscribeKeyChainStoreServiceKey;
    
    NSString *itemKey = NSStringNONil(order.productId);
    NSString *itemValue = NSStringNONil([order modelString]);
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:service];
    [store removeAllItems];
    
    NSString *string = [store stringForKey:itemKey];
    NSArray *arr = [string componentsSeparatedByString:MBPayKeyChainStoreValueSeparateKey];
    NSMutableArray *muArr = [NSMutableArray arrayWithArray:arr];
    [muArr addObject:itemValue];
    
    if (muArr.count > 10) {
        [muArr removeObjectAtIndex:0];
    }
    
    NSString *result = [muArr componentsJoinedByString:MBPayKeyChainStoreValueSeparateKey];
    
    [store setString:result forKey:itemKey];
}

+ (void)deleteOrder:(MBPayOrderItem *)order
{
    if (!order) {
        return;
    }
    
    NSString *service = MBPayKeyChainStoreServiceKey;
    
    NSString *itemKey = NSStringNONil(order.productId);
    NSString *itemValue = NSStringNONil([order modelString]);
    
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:service];

    NSString *string = [store stringForKey:itemKey];
    NSArray *arr = [string componentsSeparatedByString:MBPayKeyChainStoreValueSeparateKey];
    NSMutableArray *muArr = [NSMutableArray arrayWithArray:arr];
    [muArr removeObject:itemValue];
    NSString *result = [muArr componentsJoinedByString:MBPayKeyChainStoreValueSeparateKey];
    
    if (kIsEmptyString(result)) {
        [store removeItemForKey:itemKey];
    }else
    {
        [store setString:result forKey:itemKey];
    }
}

+ (NSArray <MBPayOrderItem *>*)ordersWithProductId:(NSString *)productId
{
    NSString *service = MBPayKeyChainStoreServiceKey;
    
    NSString *itemKey = NSStringNONil(productId);
    
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:service];
    NSString *string = [store stringForKey:itemKey];
    
    NSMutableArray *orders = [NSMutableArray array];
    NSArray *arr = [string componentsSeparatedByString:MBPayKeyChainStoreValueSeparateKey];
    for (NSString *value in arr) {
        MBPayOrderItem *item = [MBPayOrderItem createFromString:value];
        if (item) {
            [orders addObject:item];
        }
    }
    
    return orders;
}

+ (NSArray <MBPayOrderItem *>*)subscribeOrdersWithProductId:(NSString *)productId
{
    NSString *service = MBPaySubscribeKeyChainStoreServiceKey;
    
    NSString *itemKey = NSStringNONil(productId);
    
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:service];
    NSString *string = [store stringForKey:itemKey];
    
    NSMutableArray *orders = [NSMutableArray array];
    NSArray *arr = [string componentsSeparatedByString:MBPayKeyChainStoreValueSeparateKey];
    for (NSString *value in arr) {
        MBPayOrderItem *item = [MBPayOrderItem createFromString:value];
        if (item) {
            [orders addObject:item];
        }
    }
    
    return orders;
}

+ (NSArray <MBPayOrderItem *>*)allSubscribeOrders
{
    NSString *service = MBPaySubscribeKeyChainStoreServiceKey;
        
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:service];
    
    NSArray *allKeys = [store allKeys];
    
    NSMutableArray *orders = [NSMutableArray array];
    
    for (NSString *itemKey in allKeys) {
        NSString *string = [store stringForKey:itemKey];
        NSArray *arr = [string componentsSeparatedByString:MBPayKeyChainStoreValueSeparateKey];
        for (NSString *value in arr) {
            MBPayOrderItem *item = [MBPayOrderItem createFromString:value];
            if (item) {
                [orders addObject:item];
            }
        }
    }
    return orders;
}

+ (BOOL)hasOneOrderWithProductId:(NSString *)productId uid:(NSString *)uid
{
    NSArray *items = [self ordersWithProductId:productId];
    
    for (MBPayOrderItem *item in items) {
        
        if ([item.uid isEqualToString:uid] && (time(NULL) - item.createTime < 5 * 60)) {
            return YES;
        }else if ([item.uid isEqualToString:uid] && (time(NULL) - item.createTime > 24 * 60 * 60)) {
            [self deleteOrder:item];
        }
        
        MBLogI(@"#pay# keychain orders %@ %@ %@",
               NSStringNONil(item.productId),
               NSStringNONil(item.uid),
               NSStringNONil(item.orderId));
    }

    return NO;
}

@end
