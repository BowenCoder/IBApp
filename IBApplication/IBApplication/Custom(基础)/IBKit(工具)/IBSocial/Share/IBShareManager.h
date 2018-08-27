//
//  IBShareManager.h
//  IBApplication
//
//  Created by Bowen on 2018/8/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBSocialManager.h"

typedef void(^IBSuccessBlock)(id response);
typedef void(^IBFailureBlock)(NSError *error);

@interface IBShareManager : NSObject

+ (instancetype)manager;

- (void)shareToQQ:(IBShareObject *)model success:(IBSuccessBlock)success failure:(IBFailureBlock)failure;


@end
