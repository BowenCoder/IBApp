//
//  MBPayVerificator.h
//  MBApplePay
//
//  Created by Bowen on 2020/5/8.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMStore.h"

static const NSInteger maxRetryCount = 3;

NS_ASSUME_NONNULL_BEGIN

@interface MBPayVerificator : NSObject <RMStoreReceiptVerificator>

@end

NS_ASSUME_NONNULL_END
