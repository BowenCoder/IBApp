//
//  MBAutoTrackerModule.h
//  IBApplication
//
//  Created by Bowen on 2020/1/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBModuleCenter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBAutoTrackerModule : NSObject <MBModuleProtocol>

+ (instancetype)module;
- (void)setup;

@end

NS_ASSUME_NONNULL_END
