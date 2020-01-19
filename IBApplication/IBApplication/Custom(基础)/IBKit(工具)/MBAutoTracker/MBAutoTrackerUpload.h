//
//  MBAutoTrackerUpload.h
//  IBApplication
//
//  Created by Bowen on 2020/1/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBAutoTrackerUpload : NSObject

+ (void)setup;
+ (void)trackAppTerminate;
+ (void)trackAppDidBecomeActive;
+ (void)trackAppDidEnterBackground;
+ (void)trackViewPath:(NSString *)viewPath;
+ (void)trackPageInWithName:(NSString *)pageName time:(NSString *)time enterPath:(NSString *)path;
+ (void)trackPageOutWithName:(NSString *)pageName time:(NSString *)time;

@end

NS_ASSUME_NONNULL_END
