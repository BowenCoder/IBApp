//
//  NSDictionary+Ext.h
//  IBApplication
//
//  Created by Bowen on 2018/9/17.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Ext)

- (NSArray *)mb_arrayForKey:(NSString *)keyPath;

- (NSNumber *)mb_numberForKey:(NSString *)keyPath;

- (NSString *)mb_stringForKey:(NSString *)keyPath;

- (NSDictionary *)mb_dictionaryForKey:(NSString *)keyPath;

@end

@interface NSMutableDictionary (Ext)

- (void)mb_setObject:(id)value forKey:(id)key;

@end
