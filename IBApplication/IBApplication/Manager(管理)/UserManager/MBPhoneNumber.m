//
//  MBPhoneNumber.m
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBPhoneNumber.h"

@implementation MBPhoneNumber

+ (instancetype)phoneNumber:(NSString *)number dialCode:(NSString *)dialCode
{
    MBPhoneNumber *phoneNumber = [[MBPhoneNumber alloc] init];
    phoneNumber.number = number;
    phoneNumber.dialCode = dialCode;
    return phoneNumber;
}

- (NSString *)number {
    if (!_number) {
        _number = @"";
    }
    return _number;
}

- (NSString *)dialCode {
    if (!_dialCode) {
        _dialCode = @"";
    }
    return _dialCode;
}


@end
