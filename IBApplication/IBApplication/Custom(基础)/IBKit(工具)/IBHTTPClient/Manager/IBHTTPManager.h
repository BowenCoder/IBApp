//
//  IBHTTPManager.h
//  IBApplication
//
//  Created by Bowen on 2019/6/17.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface IBHTTPManager : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

NS_ASSUME_NONNULL_END
