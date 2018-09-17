//
//  NSDictionary+Ext.h
//  IBApplication
//
//  Created by Bowen on 2018/9/17.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Ext)

- (NSArray *)arrayForKey:(NSString *)keyPath;

- (NSNumber *)numberForKey:(NSString *)keyPath;

- (NSString *)stringForKey:(NSString *)keyPath;

- (NSDictionary *)dictionaryForKey:(NSString *)keyPath;


@end
