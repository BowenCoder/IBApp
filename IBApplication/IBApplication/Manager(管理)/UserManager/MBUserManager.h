//
//  MBUserManager.h
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBUserManager : NSObject

+ (instancetype)sharedManager;

- (void)restore;

- (MBUserModel *)loginUser;

- (void)setLoginUser:(MBUserModel *)user;

// 原子参数设置专用
- (void)setLogin:(NSInteger)uid session:(NSString *)session phoneNum:(MBPhoneNumber *)phoneNumber;

- (void)refreshLoginUser:(dispatch_block_t)completion;

- (BOOL)isLoginUser:(MBUserModel *)user;

- (BOOL)isLogin;

- (void)saveUserInfo;

- (void)logout;

@end

NS_ASSUME_NONNULL_END
