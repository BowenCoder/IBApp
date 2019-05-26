//
//  IBAtomFactory.h
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IBAtomFactory : NSObject

+ (instancetype)sharedInstance;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
