//
//  MBSocketCompeletionManager.h
//  IBApplication
//
//  Created by Bowen on 2020/6/12.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBSocketCMDType.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBSocketCompeletionManager : NSObject

@property (nonatomic, assign) NSInteger messageTimeout;

- (void)setCompeletion:(MBSocketRspCallback)compeletion forKey:(NSString *)key;

- (MBSocketRspCallback)compeletionForKey:(NSString *)key;

- (void)registerMessageCompeletion:(MBSocketRspCallback)compeletion key:(NSString *)key target:(id)target;

- (NSArray *)registerMessageCompeletionsForKey:(NSString *)key;

- (void)removeCompeletionForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
