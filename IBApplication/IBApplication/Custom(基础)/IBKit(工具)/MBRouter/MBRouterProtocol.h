//
//  MBRouterProtocol.h
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBRouterRequest.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MBRouterProtocol <NSObject>

+ (BOOL)openRequest:(MBRouterRequest *)request application:(UIApplication *)application annotation:(id)annotation target:(UIViewController *)target;

@end

NS_ASSUME_NONNULL_END
