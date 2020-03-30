//
//  NSPointerArray+Ext.h
//  IBApplication
//
//  Created by Bowen on 2020/3/30.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPointerArray (Ext)

- (NSUInteger)fb_indexOfPointer:(nullable void *)pointer;

- (BOOL)fb_containsPointer:(nullable void *)pointer;

@end

NS_ASSUME_NONNULL_END
