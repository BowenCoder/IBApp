//
//  IBPassword.h
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Password strength level enum, from 0 (min) to 6 (max)
 */
typedef NS_ENUM(NSInteger, PasswordStrengthLevel) {
    /**
     *  Password strength very weak
     */
    PasswordStrengthLevelVeryWeak = 0,
    /**
     *  Password strength weak
     */
    PasswordStrengthLevelWeak,
    /**
     *  Password strength average
     */
    PasswordStrengthLevelAverage,
    /**
     *  Password strength strong
     */
    PasswordStrengthLevelStrong,
    /**
     *  Password strength very strong
     */
    PasswordStrengthLevelVeryStrong,
    /**
     *  Password strength secure
     */
    PasswordStrengthLevelSecure,
    /**
     *  Password strength very secure
     */
    PasswordStrengthLevelVerySecure
};

/**
 *  This class adds some useful methods to manage passwords
 */
@interface IBPassword : NSObject

/**
 *  Check the password strength level
 *
 *  @param password Password string
 *
 *  @return Returns the password strength level with value from enum PasswordStrengthLevel
 */
+ (PasswordStrengthLevel)checkPasswordStrength:(NSString *)password;

@end
