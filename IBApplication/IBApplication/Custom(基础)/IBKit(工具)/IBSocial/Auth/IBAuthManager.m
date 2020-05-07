//
//  IBAuthManager.m
//  IBApplication
//
//  Created by Bowen on 2018/8/29.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBAuthManager.h"

@interface IBAuthManager () <IBSocialDelegate>

@property (nonatomic, copy) IBSuccessBlock successBlock;
@property (nonatomic, copy) IBFailureBlock failureBlock;

@end

@implementation IBAuthManager

+ (instancetype)manager {
    IBAuthManager *manager = [[IBAuthManager alloc] init];
    [IBSocialManager manager].delegate = manager;
    return manager;
}

- (void)loginQQ:(IBSuccessBlock)success failure:(IBFailureBlock)failure {
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    [[IBSocialManager manager].tecentAuth authorize:@[@"get_user_info", @"get_simple_userinfo", @"add_t"]];
}

- (void)loginWechat:(IBSuccessBlock)success failure:(IBFailureBlock)failure {
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"bowen";
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

- (void)loginSina:(IBSuccessBlock)success failure:(IBFailureBlock)failure {
    
    self.successBlock = success;
    self.failureBlock = failure;
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = @"http://www.sina.com";
    request.scope = @"all";
    [WeiboSDK sendRequest:request];

}

- (void)clearData {
    self.successBlock = nil;
    self.failureBlock = nil;
    [IBSocialManager manager].delegate = nil;
}

#pragma mark - IBSocialDelegate

- (void)auth:(id)result error:(NSError *)error {
    if (!error && self.successBlock) {
        self.successBlock(result);
    } else {
        self.failureBlock(error);
    }
    [self clearData];
}

@end
