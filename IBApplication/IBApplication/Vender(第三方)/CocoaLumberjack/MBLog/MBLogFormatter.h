//
//  MBLogFormatter.h
//  IBApplication
//
//  Created by Bowen on 2019/5/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "DDDispatchQueueLogFormatter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBLogFormatter : DDDispatchQueueLogFormatter <DDLogFormatter>

@end

@interface MBXcodeLogFormatter : DDDispatchQueueLogFormatter <DDLogFormatter>

@end

@interface MBASLLogFormatter : DDDispatchQueueLogFormatter <DDLogFormatter>

@end


NS_ASSUME_NONNULL_END
