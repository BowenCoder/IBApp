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

- (void)setObject:(id<NSCoding>)object forUrl:(NSString *)url cacheTime:(NSTimeInterval)time;

- (void)objectForUrl:(NSString *)url withBlock:(void(^)(id<NSCoding> object))block cacheTime:(NSTimeInterval)time;

- (void)removeAllCaches;

@end

NS_ASSUME_NONNULL_END
