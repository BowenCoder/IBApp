//
//  MBLogMacros.h
//  IBApplication
//
//  Created by Bowen on 2019/5/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#ifndef MBLogMacros_h
#define MBLogMacros_h

#import "CocoaLumberjack.h"

/**
 错误日志
 */
#define MBLogE(frmt, ...)  LOG_MAYBE(NO,                LOG_LEVEL_DEF, DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

/**
 警告日志
 */
#define MBLogW(frmt, ...)  LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

/**
 信息日志
 */
#define MBLogI(frmt, ...)  LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

/**
 调试日志
 */
#define MBLogD(frmt, ...)  LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

/**
 详细日志
 */
#define MBLogV(frmt, ...)  LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define MBLog MBLogD


#endif /* MBLogMacros_h */
