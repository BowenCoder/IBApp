//
//  MBAppStorePayLog.h
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 bowen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBAppStorePayLog : NSObject

#pragma mark - 苹果支付

+ (void)trackCreateWithProductId:(NSString *)productId
                           order:(NSString *)order
                           money:(NSInteger)money
                         errCode:(NSInteger)errCode
                          errMsg:(NSString *)errMsg;

+ (void)trackStartPayWithProductId:(NSString *)productId
                             order:(NSString *)order;

+ (void)trackRequestFailedWithProductId:(NSString *)productId
                                  order:(NSString *)order
                                errCode:(NSInteger)errCode
                                 errMsg:(NSString *)errMsg;

+ (void)trackIAPWithProductId:(NSString *)productId
                        order:(NSString *)order
                transactionId:(NSString *)transactionId
                      errCode:(NSInteger)errCode
                       errMsg:(NSString *)errMsg;

+ (void)trackUserCancelWithProductId:(NSString *)productId
                               order:(NSString *)order;

+ (void)trackAgreeWithProductId:(NSString *)productId
                          order:(NSString *)order
                  transactionId:(NSString *)transactionId
                        errCode:(NSInteger)errCode
                         errMsg:(NSString *)errMsg
                           body:(NSDictionary *)body;

@end
