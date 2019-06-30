//
//  NSArray+Ext.h
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<__covariant ObjectType> (Ext)

/**
 *  获取index的元素
 *
 *  @param index 需要获取元素的下标
 *
 *  @return index下标的元素
 */
- (ObjectType)mb_objectAtIndex:(NSUInteger)index;

/**
 *  判断数组是都越界
 *
 *  @param index 要判断的下标
 *
 *  @return 是否越界
 */
- (BOOL)mb_containsIndex:(NSUInteger)index;

@end


@interface NSMutableArray (Ext)

/**
 *  添加一个元素
 *
 *  @return 是否添加成功
 */
- (BOOL)mb_addObject:(id)object;

/**
 *  在对应的下标插入一个元素
 *
 *  @param object 插入的元素
 *  @param index    需要插入的小标
 *
 *  @return 是否插入成功
 */
- (BOOL)mb_insertObject:(id)object atIndex:(NSUInteger)index;

/**
 *  移除对应下标的元素
 *
 *  @param index 需要移除的元素的下标
 *
 *  @return 是否移除成功
 */
- (BOOL)mb_removeObjectAtIndex:(NSUInteger)index;

/**
 *  替换相应下标的元素
 *
 *  @param index    要替换元素的下标
 *  @param object 需啊哟替换的元素
 *
 *  @return 是否替换成功
 */
- (BOOL)mb_replaceObjectAtIndex:(NSUInteger)index withObject:(id)object;

/**
 *  交换两个下标元素
 *
 *  @param fromIndex 要替换元素的下标
 *  @param toIndex 替换到的下标
 *
 *  @return 是否替换成功
 */
- (BOOL)mb_exchangeObjectAtIndex:(NSUInteger)fromIndex withObjectAtIndex:(NSUInteger)toIndex;

@end
