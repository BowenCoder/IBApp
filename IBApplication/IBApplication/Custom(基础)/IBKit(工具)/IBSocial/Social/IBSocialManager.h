//
//  IBSocialManager.h
//  IBApplication
//
//  Created by Bowen on 2018/8/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBSocialHandle.h"
#import "IBSocialDelegate.h"
#import "IBSocialObject.h"

@interface IBSocialManager : NSObject

@property (nonatomic, strong) id<IBSocialDelegate> delegate;

@property (nonatomic, strong) TencentOAuth *tecentAuth;

+ (instancetype)manager;

- (BOOL)registerSDK:(IBSocialPlatformType)platformType;
- (BOOL)supportSDK:(IBSocialPlatformType)platformType;

- (void)handleAuthResponse:(id)result error:(NSError *)error;
- (void)handleShareResponse:(id)result error:(NSError *)error;

- (BOOL)openURL:(NSURL *)url application:(UIApplication *)application annotation:(id)annotation;

@end
