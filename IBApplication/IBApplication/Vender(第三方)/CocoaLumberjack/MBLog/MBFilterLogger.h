//
//  MBFilterLogger.h
//  IBApplication
//
//  Created by Bowen on 2019/5/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "DDLog.h"

// Disable legacy macros
#ifndef DD_LEGACY_MACROS
#define DD_LEGACY_MACROS 0
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol MBLogFilterDelegate <NSObject>

@optional
- (void)onLogMessage:(NSString *)rawMessage;

@end


@interface MBFilterLogger : DDAbstractLogger

- (void)addFilter:(id<MBLogFilterDelegate>)filter;
- (void)removeFilter:(id<MBLogFilterDelegate>)filter;

@end

NS_ASSUME_NONNULL_END
