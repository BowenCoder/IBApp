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

@property (nonatomic, readonly, strong) MBUserModel *loginUser;
@property (nonatomic, readonly, assign) BOOL isLogin;

+ (instancetype)sharedManager;

/**
 退出登录
 */
- (void)logout;

/**
 判断是否是登录用户
 */
- (BOOL)isLoginUser:(NSString *)uid;

/**
 更新或者设置用户数据
 */
- (void)updateLoginUser:(MBUserModel *)user;

/**
 网络刷新用户数据
 */
- (void)refreshLoginUser:(dispatch_block_t)completion;

/**
 原子参数设置专用

 @param uid uid
 @param session sessionID
 @param phoneNumber 电话
 */
- (void)setLogin:(NSString *)uid session:(NSString *)session phoneNum:(MBPhoneNumber *)phoneNumber;

@end

NS_ASSUME_NONNULL_END
