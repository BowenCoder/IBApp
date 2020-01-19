//
//  MBLaunchSetup.h
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBLaunchSetup : NSObject

+ (void)loggerSetup;

+ (void)userSetup;

+ (void)moduleSetup;

+ (void)routerSetup;

+ (void)shareSetup;

+ (void)buglySetup;

+ (void)trackSetup;

+ (void)buglyUidSetup:(NSInteger)uid;

+ (void)WKWebViewSetup;

@end

NS_ASSUME_NONNULL_END
