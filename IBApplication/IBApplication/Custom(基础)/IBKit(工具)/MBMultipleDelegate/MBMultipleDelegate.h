//
//  MBMultipleDelegate.h
//  IBApplication
//
//  Created by Bowen on 2020/3/30.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
*  让所有 NSObject 都支持多个 delegate，默认只支持属性名为 delegate 的 delegate（特别地，UITableView 和 UICollectionView 额外默认支持 dataSource）。
*  使用方式：将 fb_multipleDelegateEnabled 置为 YES 后像平时一样 self.delegate = xxx 即可。
*  如果你要清掉所有的 delegate，则像平时一样 self.delegate = nil 即可。
*  如果你把 delegate 同时赋值给 objA 和 objB，而你只要移除 objB，则可：[self fb_removeDelegate:objB]
*
*  如果你要让其他命名的 delegate 属性也支持多 delegate，则可调用 qmui_registerDelegateSelector: 方法将该属性的 getter 传进去，再进行实际的 delegate 赋值，例如你的 delegate 命名为 abcDelegate，则你可以这么写：
*  [self fb_registerDelegateSelector:@selector(abcDelegate)];
*  self.abcDelegate = delegateA;
*  self.abcDelegate = delegateB;
*
*  @warning 不支持 self.delegate = self 的写法，会引发死循环，有这种需求的场景建议在 self 内部使用 MBWeakProxy。
*/
@interface NSObject (delegates)

/// 当你需要当前的 class 支持多个 delegate，请将此属性置为 YES。默认为 NO。
@property(nonatomic, assign) BOOL fb_multipleDelegateEnabled;

/// 让某个 delegate 属性也支持多 delegate 模式（默认只帮你加了 @selector(delegate) 的支持，如果有其他命名的 property 就需要自己用这个方法添加）
- (void)fb_registerDelegateSelector:(SEL)getter;

/// 移除某个特定的 delegate 对象，例如假设你把 delegate 同时赋值给 objA 和 objB，而你只要移除 objB，则可：[self qmui_removeDelegate:objB]。但如果你想同时移除 objA 和 objB（也即全部 delegate），则像往常一样直接 self.delegate = nil 即可。
- (void)fb_removeDelegate:(id)delegate;

@end

@interface MBMultipleDelegate : NSObject

@property(nonatomic, weak) NSObject *parentObject;

@property(nonatomic, strong, readonly) NSPointerArray *delegates;

+ (instancetype)weakDelegate;

+ (instancetype)strongDelegate;

- (void)addDelegate:(id)delegate;

- (BOOL)removeDelegate:(id)delegate;

- (void)removeAllDelegates;

- (BOOL)containsDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
