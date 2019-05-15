//
//  MBLogger.h
//  IBApplication
//
//  Created by Bowen on 2019/5/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLumberjack.h"
#import "MBFilterLogger.h"
#import "MBErrorCheck.h"
#import "MBLogMacros.h"

NS_ASSUME_NONNULL_BEGIN

extern const DDLogLevel ddLogLevel;

@interface MBLogger : NSObject

@property(nonatomic, readonly) MBFilterLogger *filterLogger;
@property(nonatomic, readonly) NSString *logsDirectory;

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

- (void)start;
- (void)stop;
- (NSString *)zipLogFiles;

@end

@interface MBLogTraceStack : NSObject

- (instancetype)initWithFile: (const char*)file Function: (const char*)func Line: (int)line;
- (void)nothing;

@end

#define MBTraceStack \
MBLogTraceStack *__MBTraceStack__; \
if(ddLogLevel != DDLogLevelOff){\
    __MBTraceStack__ = [[MBLogTraceStack alloc] initWithFile:__FILE__ Function:__PRETTY_FUNCTION__ Line:__LINE__];\
    [__MBTraceStack__ nothing];\
}\



NS_ASSUME_NONNULL_END
