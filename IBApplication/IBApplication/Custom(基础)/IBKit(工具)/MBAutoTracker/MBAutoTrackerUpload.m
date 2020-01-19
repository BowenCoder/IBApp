//
//  MBAutoTrackerUpload.m
//  IBApplication
//
//  Created by Bowen on 2020/1/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBAutoTrackerUpload.h"
#import "MBLogger.h"

@interface MBAutoTrackerUpload ()

@property (nonatomic, copy) NSArray *viewPathFilterArray;

@end

@implementation MBAutoTrackerUpload

+ (instancetype)sharedInstance
{
    static MBAutoTrackerUpload *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MBAutoTrackerUpload alloc] init];
    });
    return instance;
}

+ (void)setup
{
    [MBAutoTrackerUpload requestFilterData];
    [MBAutoTrackerUpload trackHeartBeat];
}

+ (void)trackHeartBeat
{

}

+ (void)trackAppTerminate
{
    
}

+ (void)trackAppDidBecomeActive
{
    
}

+ (void)trackAppDidEnterBackground
{
    
}

+ (void)trackViewPath:(NSString *)viewPath
{
    if (!viewPath) {
        return;
    }
    MBLogD(@"#trackdata# viewPath: %@", viewPath);
    
    if (![self filtersContainString:viewPath]) {
        MBLogD(@"\n#trackdata# NO TRACKING");
        return;
    }
    // 上传
}

+ (void)trackPageInWithName:(NSString *)pageName time:(NSString *)time enterPath:(NSString *)path;
{
    MBLogD(@"#trackdata# page in: [%@], pageInTime: %@, enterPath: [%@]", pageName, time, path);
}

+ (void)trackPageOutWithName:(NSString *)pageName time:(NSString *)time
{
    MBLogD(@"#trackdata# page out: %@, pageOutTime: %@", pageName, time);
}

+ (BOOL)filtersContainString:(NSString *)string {
    return YES;
}

+ (void)requestFilterData
{
    
}

@end
