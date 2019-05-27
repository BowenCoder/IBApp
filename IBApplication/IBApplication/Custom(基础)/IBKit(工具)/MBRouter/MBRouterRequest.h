//
//  MBRouterRequest.h
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kRouterPageName @"pname"
#define kRouterSourceApplication @"source_app"

typedef void(^MBRouterResultCallback)(NSError *error, NSDictionary *responseObject);


@interface MBRouterRequest : NSObject

/** URL字符串 */
@property (nonatomic, copy) NSString *URLString;

/** 目标页面的回调处理 */
@property (nonatomic, copy) MBRouterResultCallback resultCallback;

/** URL的页面名称 */
@property (nonatomic, copy, readonly) NSString *pName;

/** URL的scheme */
@property (nonatomic, copy, readonly) NSString *scheme;

/** URL的所有参数 */
@property (nonatomic, strong, readonly) NSDictionary *options;

/** URL的应用来源 */
@property (nonatomic, copy, readonly) NSString *sourceApplication;

+ (instancetype)requestWithURLString:(NSString *)URLString resultCallback:(MBRouterResultCallback)resultCallback;

@end

NS_ASSUME_NONNULL_END
