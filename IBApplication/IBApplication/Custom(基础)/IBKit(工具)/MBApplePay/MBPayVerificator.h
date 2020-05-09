//
//  MBPayVerificator.h
//  MBApplePay
//
//  Created by Bowen on 2020/5/8.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBApplePay.h"

static const NSInteger maxRetryCount = 3;

extern NSString * const kVerifyReceiptUrl;

NS_ASSUME_NONNULL_BEGIN

@interface MBPayVerificator : NSObject <MBPayReceiptVerifier>

@end

NS_ASSUME_NONNULL_END
