//
//  MBPhoneNumber.h
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBPhoneNumber : IBModel

+ (instancetype)phoneNumber:(NSString *)number dialCode:(NSString *)dialCode;

@property (nonatomic, copy) NSString *dialCode;
@property (nonatomic, copy) NSString *number;

@end

NS_ASSUME_NONNULL_END
