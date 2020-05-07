//
//  MBApplePayModel.h
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBPayRequest.h"
#import "MBPayDelegate.h"

extern NSString * const kVerifyReceiptUrl;

@interface MBApplePayModel : NSObject

@property (nonatomic, weak) id<MBPayDelegate> delegate;

- (void)createPaymentWithProduct:(MBPayRequest *)request;

- (void)prepareAppleProductList:(NSArray<MBPayProduct *> *)products;

- (void)checkCachedApplePay;

- (void)checkLocalSubscribeOrder;

- (void)restoreApplePay;

- (void)stopRetry;

@end
