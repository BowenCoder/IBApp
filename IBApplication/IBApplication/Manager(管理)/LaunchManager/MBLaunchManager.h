//
//  MBLaunchManager.h
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBLaunchManager : NSObject

+ (MBLaunchManager *)sharedInstance;

- (void)willFinishLaunching:(NSDictionary *)launchOptions;

- (void)didFinishLaunching:(NSDictionary *)launchOptions;

- (void)loginAccount;

- (void)logoutAccount;

- (void)pushViewController:(UIViewController *)vc animated:(BOOL)animated;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;

- (UIViewController *)popViewControllerWithLevel:(NSInteger)level animated:(BOOL)animated;

- (BOOL)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion;

/**
 *  检查更新
 */
- (void)checkAppUpdateWithshowOption:(BOOL)showOption;

/**
 *  上传用户设备信息
 */
- (void)uploadUserDeviceInfo;

/**
 *  检查黑名单用户
 */
-(void)checkBlack;


@end

NS_ASSUME_NONNULL_END
