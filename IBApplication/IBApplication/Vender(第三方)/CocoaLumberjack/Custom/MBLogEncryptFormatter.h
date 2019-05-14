//
//  MBLogEncryptFormatter.h
//  IBApplication
//
//  Created by Bowen on 2019/5/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBLogFormatter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBLogEncryptFormatter : MBLogFormatter

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithEncryptKey:(NSString*)key NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
