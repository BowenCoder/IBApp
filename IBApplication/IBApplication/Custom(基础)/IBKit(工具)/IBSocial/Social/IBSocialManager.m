
//
//  IBSocialManager.m
//  IBApplication
//
//  Created by Bowen on 2018/8/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBSocialManager.h"
#import "SDKMacros.h"

@interface IBSocialManager () <TencentSessionDelegate>

@property (nonatomic, assign) BOOL registerQQ;
@property (nonatomic, assign) BOOL registerWechat;
@property (nonatomic, assign) BOOL registerSina;

@end

@implementation IBSocialManager

+ (instancetype)manager {
    static IBSocialManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[IBSocialManager alloc] init];
        manager.registerQQ = NO;
        manager.registerSina = NO;
        manager.registerWechat = NO;
    });
    return manager;
}

#pragma mark - public method

- (BOOL)openURL:(NSURL *)url application:(UIApplication *)application annotation:(id)annotation {
    
    BOOL result = NO;
    
    if ([url.scheme hasPrefix:@"tencent"]) {
        result = [QQApiInterface handleOpenURL:url delegate:[IBSocialHandle delegate]];
        if (!result) {
            result = [TencentOAuth HandleOpenURL:url];
        }
        
    } else if([url.scheme hasPrefix:@"wb"]) {
        result = [WeiboSDK handleOpenURL:url delegate:[IBSocialHandle delegate]];
        
    } else if([url.scheme hasPrefix:@"wx"]) {
        result = [WXApi handleOpenURL:url delegate:[IBSocialHandle delegate]];
        
    }
    return result;
}

- (void)handleAuthResponse:(id)result error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(auth:error:)]) {
        [self.delegate auth:result error:error];
    }
}

- (void)handleShareResponse:(id)result error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(share:error:)]) {
        [self.delegate share:result error:error];
    }
}

- (BOOL)registerSDK:(IBSocialPlatformType)platformType {
    BOOL result;
    switch (platformType) {
        case IBSocialPlatformQQ:
            result =[self _registerQQ];
            break;
        case IBSocialPlatformWechat:
            result = [self _registerWechat];
            break;
        case IBSocialPlatformSina:
//            result = [self _registerSina];
            break;
        default:
            result = NO;
            break;
    }
    return result;
}

- (BOOL)supportSDK:(IBSocialPlatformType)platformType {
    BOOL result;
    switch (platformType) {
        case IBSocialPlatformQQ:
            result = [QQApiInterface isQQSupportApi] && [QQApiInterface isQQInstalled];
            break;
        case IBSocialPlatformWechat:
            result = [WXApi isWXAppSupportApi] && [WXApi isWXAppInstalled];
            break;
        case IBSocialPlatformSina:
            result = [WeiboSDK isCanShareInWeiboAPP] && [WeiboSDK isWeiboAppInstalled];
            break;            
        default:
            result = NO;
            break;
    }
    return result;
}

#pragma mark - private method

- (BOOL)_registerQQ {
    if (!self.registerQQ) {
        NSAssert(wechatKey != nil, @"QQ的appkey不能为空");
        self.tecentAuth = [[TencentOAuth alloc] initWithAppId:QQKey andDelegate:self];
    }
    return self.registerQQ;
}

- (BOOL)_registerWechat {
    if (!self.registerWechat) {
        NSAssert(wechatKey != nil, @"微信的appkey不能为空");
        self.registerWechat = [WXApi registerApp:wechatKey];
    }
    return self.registerWechat;
}

- (BOOL)_registerSina {
    if (!self.registerSina) {
        NSAssert(wechatKey != nil, @"微博的appkey不能为空");
        self.registerSina = [WeiboSDK registerApp:sinaKey];
    }
    return self.registerSina;
}


#pragma mark - TencentSessionDelegate

/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin {
    if(self.tecentAuth.accessToken && self.tecentAuth.accessToken.length != 0) {
        if (![self.tecentAuth getUserInfo]) {
            NSError *err = [NSError errorWithDomain:@"授权失败" code:kOpenSDKErrorUnknown userInfo:nil];
            [self handleAuthResponse:nil error:err];
        } else {
            self.registerQQ = YES;
        }
    } else {
        NSError *err = [NSError errorWithDomain:@"授权失败" code:kOpenSDKErrorUnknown userInfo:nil];
        [self handleAuthResponse:nil error:err];
    }
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled {
    NSError *err = [NSError errorWithDomain:@"授权失败" code:kOpenSDKErrorUnknown userInfo:nil];
    [self handleAuthResponse:nil error:err];
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork {
    NSError *err = [NSError errorWithDomain:@"没有网络" code:kOpenSDKErrorNetwork userInfo:nil];
    [self handleAuthResponse:nil error:err];
}

#pragma mark - TencentSessionDelegate

/**
 * 获取用户个人信息回调
 */
- (void)getUserInfoResponse:(APIResponse*) response {
    
    IBSocialResponse *res = [[IBSocialResponse alloc] init];
    res.openid = self.tecentAuth.openId;
    res.accessToken = self.tecentAuth.accessToken;
    res.unionId = self.tecentAuth.unionid;
    res.expiration = self.tecentAuth.expirationDate;
    
    NSDictionary *params = @{
                             @"auth" : res,
                             @"info" : response.jsonResponse
                             };
    [self handleAuthResponse:params error:nil];
}


@end
