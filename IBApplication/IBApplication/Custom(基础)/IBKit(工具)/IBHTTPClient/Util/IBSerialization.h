//
//  IBSerialization.h
//  IBApplication
//
//  Created by BowenCoder on 2019/7/6.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IBSerialization : NSObject

+ (NSData *)serializeJsonDataWithDict:(NSDictionary *)dict;

+ (NSString *)serializeJsonStringWithDict:(NSDictionary *)dict;

+ (NSArray *)unSerializeArrayWithJsonData:(NSData *)data error:(NSError **)error;

+ (NSArray *)unSerializeArrayWithJsonString:(NSString *)jsonStr error:(NSError **)error;

+ (NSDictionary *)unSerializeWithJsonData:(NSData *)data error:(NSError **)error;

+ (NSDictionary *)unSerializeWithJsonString:(NSString *)jsonStr error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
