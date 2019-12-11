//
//  MBLaunchSetup.m
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBLaunchSetup.h"
#import <WebKit/WKWebsiteDataRecord.h>
#import <WebKit/WKWebsiteDataStore.h>
#import "MBLogger.h"
#import "MBUserManager.h"

@implementation MBLaunchSetup

+ (void)loggerSetup
{
    [[MBLogger sharedInstance] start];
}

+ (void)userSetup
{
    [[MBUserManager sharedManager] refreshLoginUser:^{
        
    }];
}

// 注册MBModuleCenter
+ (void)moduleSetup
{
    
}

+ (void)shareSetup
{
    
}

+ (void)buglySetup
{
    
}

+ (void)buglyUidSetup:(NSInteger)uid
{
    
}

+ (void)routerSetup
{
    
}

+ (void)WKWebViewSetup
{
    if ([[UIDevice currentDevice].systemVersion floatValue] > 9.0) {
        //// Optional data
        NSSet *websiteDataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeOfflineWebApplicationCache, WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeLocalStorage]];
        
        //// Date from
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        //// Execute
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            // Done
        }];
    }
}


@end
