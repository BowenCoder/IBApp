//
//  IBSocialHandle.m
//  IBApplication
//
//  Created by Bowen on 2018/8/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBSocialHandle.h"
#import "IBSocialManager.h"

@interface IBSocialHandle ()

@end

@implementation IBSocialHandle

+ (instancetype)delegate {
    return [[IBSocialHandle alloc] init];
}

#pragma mark - QQApiInterfaceDelegate,WXApiDelegate

- (void)onResp:(NSObject *)resp {
    if ([resp isKindOfClass:[QQBaseResp class]]) {
        [self qqOnResp:(QQBaseResp *)resp];
    } else {
        [self wechatOnResp:(BaseResp *)resp];
    }
}

- (void)onReq:(NSObject *)req {
    if ([req isKindOfClass:[QQBaseResp class]]) {
        
    } else {
        
    }
}

#pragma mark - QQ

/**
 处理QQ在线状态的回调
 */
- (void)isOnlineResponse:(NSDictionary *)response {
    
}

/**
 处理来至QQ的响应
 */
- (void)qqOnResp:(QQBaseResp *)resp {
    
    NSError *err = nil;
    
    if (resp.type != ESENDMESSAGETOQQRESPTYPE) {
        return;
    }
    
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        IBSocialResponse *rsp = [[IBSocialResponse alloc] init];
        rsp.originalResponse = resp;
        
        NSInteger code = [resp.result integerValue];
        
        if (code != 0) {
            NSString *errMsg = resp.errorDescription ?: @"分享失败";
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey : errMsg
                                       };
            err = [NSError errorWithDomain:NSCocoaErrorDomain code:code userInfo:userInfo];
        }
        [[IBSocialManager manager] handleShareResponse:rsp error:err];
    }
}

#pragma mark - wechat

/**
 处理来至微信的响应
 */
- (void)wechatOnResp:(BaseResp *)resp {
    
    NSError *err = nil;
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        IBSocialResponse *rsp = [[IBSocialResponse alloc] init];
        rsp.originalResponse = resp;
        
        if (resp.errCode != WXSuccess) {
            NSString     *errMsg   = resp.errStr ?: @"授权失败";
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey : errMsg
                                       };
            err = [NSError errorWithDomain:NSCocoaErrorDomain code:resp.errCode userInfo:userInfo];
        }
        [[IBSocialManager manager] handleAuthResponse:rsp error:err];
        
    } else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        IBSocialResponse *rsp = [[IBSocialResponse alloc] init];
        rsp.originalResponse = resp;
        NSString     *errMsg;
        if (resp.errCode != WXSuccess) {
            errMsg   = resp.errStr ?: @"分享失败";
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey : errMsg
                                       };
            err = [NSError errorWithDomain:NSCocoaErrorDomain code:resp.errCode userInfo:userInfo];
        } else {
            errMsg = resp.errStr ?: @"分享成功";
        }
        [[IBSocialManager manager] handleShareResponse:rsp error:err];
    }
}

#pragma mark - Weibo

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    NSError *err = nil;
    
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        IBSocialResponse *rsp = [[IBSocialResponse alloc] init];
        rsp.originalResponse  = response.userInfo;
        NSString *errmsg;
        
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            // 微博登录成功
            errmsg = @"微博登录成功";
            WBAuthorizeResponse *authorizeInfo = (WBAuthorizeResponse *)response;
            rsp.uid = authorizeInfo.userID;
            rsp.accessToken = authorizeInfo.accessToken;
            rsp.expiration = authorizeInfo.expirationDate;
            rsp.refreshToken = authorizeInfo.refreshToken;
        } else {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey : @"授权失败"
                                       };
            err = [NSError errorWithDomain:NSCocoaErrorDomain code:response.statusCode userInfo:userInfo];
        }
        [[IBSocialManager manager] handleAuthResponse:rsp error:err];
        
    } else if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        IBSocialResponse *rsp = [[IBSocialResponse alloc] init];
        rsp.originalResponse  = response;
        
        if (response.statusCode != WeiboSDKResponseStatusCodeSuccess) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey : @"分享失败"
                                       };
            err = [NSError errorWithDomain:NSCocoaErrorDomain code:response.statusCode userInfo:userInfo];
        }
        
        [[IBSocialManager manager] handleShareResponse:rsp error:err];
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}



@end
