//
//  MBAutoTrackerModule.m
//  IBApplication
//
//  Created by Bowen on 2020/1/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBAutoTrackerModule.h"
#import "MBAutoTrackerUpload.h"

@interface MBAutoTrackerModule ()


@end

@implementation MBAutoTrackerModule

+ (instancetype)module
{
    return [[MBAutoTrackerModule alloc] init];
}

- (void)setup
{
    [[MBModuleCenter defaultCenter] registerModule:self];
    [MBAutoTrackerUpload setup];
}

- (void)module_applicationDidBecomeActive:(UIApplication *)application
{
    [MBAutoTrackerUpload trackAppDidBecomeActive];
}

- (void)module_applicationDidEnterBackground:(UIApplication *)application
{
    [MBAutoTrackerUpload trackAppDidEnterBackground];
}

- (void)module_applicationWillTerminate:(UIApplication *)application
{
    [MBAutoTrackerUpload trackAppTerminate];
}

@end
