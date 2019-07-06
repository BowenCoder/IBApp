//
//  IBResponse.h
//  IBApplication
//
//  Created by BowenCoder on 2019/7/6.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface IBResponse : NSObject <IBResponseProtocol>

+ (instancetype)response;

@end

NS_ASSUME_NONNULL_END
