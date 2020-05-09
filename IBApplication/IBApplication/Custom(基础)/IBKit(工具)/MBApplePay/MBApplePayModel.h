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

@interface MBApplePayModel : NSObject

@property (nonatomic, weak) id<MBPayDelegate> delegate;

- (void)createPaymentWithProduct:(MBPayRequest *)request;

- (void)prepareAppleProducts:(NSArray<MBPayProduct *> *)products;

- (void)restoreApplePay;

@end
