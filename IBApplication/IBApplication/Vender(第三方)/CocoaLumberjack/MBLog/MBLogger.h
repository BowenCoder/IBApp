//
//  MBLogger.h
//  IBApplication
//
//  Created by Bowen on 2019/5/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBFilterLogger.h"
#import "MBLogMacros.h"

NS_ASSUME_NONNULL_BEGIN

extern const DDLogLevel ddLogLevel;

@interface MBLogger : NSObject

@property (nonatomic, readonly) MBFilterLogger *filterLogger;

+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;

/// 日志本地化
- (void)startFileLog;

/// Xcode控制台
- (void)startXcodeLog;

/// 苹果的日志系统
- (void)startASLLog;

/// 日志过滤
- (void)startFilter;

/// 清除日志
- (void)stop;

- (NSString *)zipLogFiles;


@end

@interface MBLogTraceStack : NSObject

+ (instancetype)traceWithFile:(const char*)file Function:(const char*)func Line:(int)line;

@end

#define MBTraceStack \
MBLogTraceStack *__MBTraceStack__; \
if(ddLogLevel != DDLogLevelOff){\
    __MBTraceStack__ = [MBLogTraceStack traceWithFile:__FILE__ Function:__PRETTY_FUNCTION__ Line:__LINE__];\
}\

NS_ASSUME_NONNULL_END
