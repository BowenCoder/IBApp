//
//  MBAppStorePayLog.m
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import "MBAppStorePayLog.h"
#import "MBLogger.h"
#import "IBMacros.h"

@interface MBAppStorePayLog ()

@end

@implementation MBAppStorePayLog

#pragma mark - 苹果支付

+ (void)trackCreateWithProductId:(NSString *)productId order:(NSString *)order money:(NSInteger)money errCode:(NSInteger)errCode errMsg:(NSString *)errMsg {
    
    NSString *name = @"order.create";
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:NSStringNONil(productId) forKey:@"product_id"];
    [dict setObject:NSStringNONil(order) forKey:@"order"];
    [dict setObject:@(money) forKey:@"money"];
    [dict setObject:@(errCode) forKey:@"code"];
    [dict setObject:NSStringNONil(errMsg) forKey:@"msg"];
    
    MBLogI(@"#apple.pay# name:%@ value:%@",name, dict);
}

+ (void)trackStartPayWithProductId:(NSString *)productId order:(NSString *)order {
    NSString *name = @"start.pay";
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:NSStringNONil(productId) forKey:@"product_id"];
    [dict setObject:NSStringNONil(order) forKey:@"order"];
    
    MBLogI(@"#apple.pay# name:%@ value:%@", name, dict);
}

+ (void)trackRequestFailedWithProductId:(NSString *)productId
                                  order:(NSString *)order
                                errCode:(NSInteger)errCode
                                 errMsg:(NSString *)errMsg {
    NSString *name = @"pay.failed";
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:NSStringNONil(productId) forKey:@"product_id"];
    [dict setObject:NSStringNONil(order) forKey:@"order"];
    [dict setObject:NSStringNONil(errMsg) forKey:@"errMsg"];
    [dict setObject:@(errCode) forKey:@"code"];
    
    MBLogI(@"#apple.pay# name:%@ value:%@", name, dict);
}

+ (void)trackIAPWithProductId:(NSString *)productId
                        order:(NSString *)order
                transactionId:(NSString *)transactionId
                      errCode:(NSInteger)errCode
                       errMsg:(NSString *)errMsg {
    NSString *name = @"pay.result";
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:NSStringNONil(productId) forKey:@"product_id"];
    [dict setObject:NSStringNONil(order) forKey:@"order"];
    [dict setObject:NSStringNONil(transactionId) forKey:@"tran_id"];
    [dict setObject:@(errCode) forKey:@"code"];
    [dict setObject:NSStringNONil(errMsg) forKey:@"msg"];
    
    MBLogI(@"#apple.pay# name:%@ value:%@", name, dict);
}

+ (void)trackUserCancelWithProductId:(NSString *)productId order:(NSString *)order {
    NSString *name = @"user.cancel";
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:NSStringNONil(productId) forKey:@"product_id"];
    [dict setObject:NSStringNONil(order) forKey:@"order"];
    
    MBLogI(@"#apple.pay# name:%@ value:%@", name, dict);
}

+ (void)trackAgreeWithProductId:(NSString *)productId order:(NSString *)order transactionId:(NSString *)transactionId errCode:(NSInteger)errCode errMsg:(NSString *)errMsg body:(NSDictionary *)body {
    NSString *name = @"pay.verify.success";
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:NSStringNONil(productId) forKey:@"product_id"];
    [dict setObject:NSStringNONil(order) forKey:@"order"];
    [dict setObject:@(errCode) forKey:@"code"];
    [dict setObject:NSStringNONil(transactionId) forKey:@"tran_id"];
    [dict setObject:NSStringNONil(errMsg) forKey:@"msg"];
    [dict setObject:NSStringNONil(body[@"order_uid"]) forKey:@"order_uid"];
    
    MBLogI(@"#apple.pay# name:%@ value:%@", name, dict);
}

@end
