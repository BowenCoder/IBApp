//
//  MBStorage.h
//  IBApplication
//
//  Created by Bowen on 2019/8/12.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBStorage : NSObject

/**
 当前用户的uid，用以区分不同登录用户，隔离存储
 */
@property (nonatomic, copy) NSString *uid;


+ (instancetype)sharedInstance;

/**
 取出对象
 @param key 对应的key
 @param ns  为防止不同业务中用了相同的key，增加了namespace加以区分业务逻辑
 @return    存储的对象
 */
+ (id)objectForKey:(NSString *)key namespace:(NSString *)ns;

/**
 存储对象
 @param object 保存的对象，需遵循<NSCoding>
 @param key    对应的key
 @param ns     为防止不同业务中用了相同的key，增加了namespace加以区分业务逻辑
 */
+ (void)setObject:(id<NSCoding>)object forKey:(NSString *)key namespace:(NSString *)ns;

/**
 移除存储对象
 @param key 对应的key
 @param ns  为防止不同业务中用了相同的key，增加了namespace加以区分业务逻辑
 */
+ (void)removeObjectForKey:(NSString *)key namespace:(NSString *)ns;

/**
 移除所有存储对象
 */
+ (void)removeAllObjects;

@end

NS_ASSUME_NONNULL_END
