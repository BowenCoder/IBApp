//
//  IBSocialHandle.h
//  IBApplication
//
//  Created by Bowen on 2018/8/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "WeiboSDK.h"

@interface IBSocialHandle : NSObject <QQApiInterfaceDelegate, WXApiDelegate, WeiboSDKDelegate>

+ (instancetype)delegate;

@end
