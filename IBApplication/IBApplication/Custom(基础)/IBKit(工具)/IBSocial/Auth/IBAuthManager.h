//
//  IBAuthManager.h
//  IBApplication
//
//  Created by Bowen on 2018/8/29.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBSocialManager.h"

@interface IBAuthManager : NSObject

+ (instancetype)manager;

- (void)loginQQ:(IBSuccessBlock)success failure:(IBFailureBlock)failure;
- (void)loginWechat:(IBSuccessBlock)success failure:(IBFailureBlock)failure;
- (void)loginSina:(IBSuccessBlock)success failure:(IBFailureBlock)failure;


@end
