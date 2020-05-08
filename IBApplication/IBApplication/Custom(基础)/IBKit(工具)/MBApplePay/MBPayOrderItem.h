//
//  MBPayOrderItem.h
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBPayRequest.h"

@interface MBPayOrderItem : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, copy) NSString *productId;
@property (nonatomic, copy) NSString *originTransationId;
@property (nonatomic, copy) NSString *transactionIdentifier;
@property (nonatomic, assign) MBPayProductType productType;

- (NSString *)modelString;

+ (MBPayOrderItem *)createFromString:(NSString *)modelString;

@end
