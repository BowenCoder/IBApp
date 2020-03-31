//
//  NSObject+Ext.h
//  IBApplication
//
//  Created by Bowen on 2019/5/15.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Ext)

/**
判断当前类是否有重写某个父类的指定方法

@param selector 要判断的方法
@param superclass 要比较的父类，必须是当前类的某个 superclass
@return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
*/
- (BOOL)fb_overrideMethod:(SEL)selector superclass:(Class)superclass;

/**
判断指定的类是否有重写某个父类的指定方法

@param selector 要判断的方法
@param superclass 要比较的父类，必须是当前类的某个 superclass
@return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
*/
+ (BOOL)fb_overrideMethod:(SEL)selector currentClass:(Class)currentClass superclass:(Class)superclass;

/**
对 super 发送消息

@param aSelector 要发送的消息
@return 消息执行后的结果
@link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method @/link
*/
- (id)fb_msgSendSuper:(SEL)aSelector;

/**
对 super 发送消息

@param aSelector 要发送的消息
@param object 作为参数传过去
@return 消息执行后的结果
@link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method @/link
*/
- (id)fb_msgSendSuper:(SEL)aSelector withObject:(nullable id)object;

/**
*  调用一个带参数的 selector，参数类型支持对象和非对象，也没有数量限制。返回值为对象或者 void。
*  @param selector 要被调用的方法名
*  @param firstArgument 参数列表，请传参数的指针地址，支持多个参数
*  @return 方法的返回值，如果该方法返回类型为 void，则会返回 nil，如果返回类型为对象，则返回该对象。
*
*  @code
*  id target = xxx;
*  SEL action = xxx;
*  UIControlEvents events = xxx;
*  [control fb_performSelector:@selector(addTarget:action:forControlEvents:) withArguments:&target, &action, &events, nil];
*  @endcode
*/
- (id)fb_performSelector:(SEL)selector withArguments:(nullable void *)firstArgument, ...;

/// 分类重写原类方法时，调用原类方法
/// @param selector 方法
/// @param param 参数
- (void)fb_performOriginalSelector:(SEL)selector param:(id)param;

@end

NS_ASSUME_NONNULL_END
