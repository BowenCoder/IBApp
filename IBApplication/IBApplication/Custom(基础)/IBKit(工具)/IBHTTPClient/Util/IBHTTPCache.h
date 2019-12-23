//
//  IBHTTPCache.h
//  IBApplication
//
//  Created by Bowen on 2019/12/11.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IBHTTPCache : NSObject

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key cacheTime:(NSTimeInterval)time;

- (void)objectForKey:(NSString *)key withBlock:(void(^)(id<NSCoding> object))block cacheTime:(NSTimeInterval)time;

- (void)removeAllCaches;

@end

NS_ASSUME_NONNULL_END
