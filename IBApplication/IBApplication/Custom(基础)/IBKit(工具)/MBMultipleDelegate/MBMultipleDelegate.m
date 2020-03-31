//
//  MBMultipleDelegate.m
//  IBApplication
//
//  Created by Bowen on 2020/3/30.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBMultipleDelegate.h"
#import "NSPointerArray+Ext.h"
#import "NSMethodSignature+Ext.h"
#import "IBMacros.h"
#import "MBInline.h"
#import "MBPropertyDescriptor.h"
#import <objc/runtime.h>
#import "RSSwizzle.h"

@interface NSObject ()

/// 用于标志“xxx.delegate = xxx”的情况
@property (nonatomic, assign) BOOL fb_delegateSelf;

@property (nonatomic, strong) NSMutableDictionary<NSString *, MBMultipleDelegate *> *fb_multipleDelegate;

@end

@implementation NSObject (delegates)

static NSMutableSet<NSString *> *fb_methodsReplacedClasses;

- (void)setFb_delegateSelf:(BOOL)fb_delegateSelf {
    objc_setAssociatedObject(self, @selector(fb_delegateSelf), @(fb_delegateSelf), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)fb_delegateSelf {
    return [objc_getAssociatedObject(self, @selector(fb_delegateSelf)) boolValue];
}

- (void)setFb_methodsReplacedClasses:(NSMutableSet *)fb_methodsReplacedClasses
{
    objc_setAssociatedObject(self, @selector(fb_methodsReplacedClasses), fb_methodsReplacedClasses, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableSet *)fb_methodsReplacedClasses
{
    return objc_getAssociatedObject(self, @selector(fb_methodsReplacedClasses));
}

- (void)setFb_multipleDelegate:(NSMutableDictionary<NSString *,MBMultipleDelegate *> *)fb_multipleDelegate
{
    objc_setAssociatedObject(self, @selector(fb_multipleDelegate), fb_multipleDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString *,MBMultipleDelegate *> *)fb_multipleDelegate
{
    return objc_getAssociatedObject(self, @selector(fb_multipleDelegate));
}

- (void)setFb_multipleDelegateEnabled:(BOOL)fb_multipleDelegateEnabled
{
    objc_setAssociatedObject(self, @selector(fb_multipleDelegateEnabled), @(fb_multipleDelegateEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (fb_multipleDelegateEnabled) {
        if (!self.fb_multipleDelegate) {
            self.fb_multipleDelegate = [NSMutableDictionary dictionary];
        }
        [self fb_registerDelegateSelector:@selector(delegate)];
        if ([self isKindOfClass:UITableView.class] || [self isKindOfClass:UICollectionView.class]) {
            [self fb_registerDelegateSelector:@selector(dataSource)];
        }
    }
}

- (BOOL)fb_multipleDelegateEnabled
{
    return [objc_getAssociatedObject(self, @selector(fb_multipleDelegateEnabled)) boolValue];
}

- (void)fb_registerDelegateSelector:(SEL)getter
{
    if (!self.fb_multipleDelegateEnabled) {
        return;
    }
        
    // 为这个 selector 创建一个 MBMultipleDelegate 容器
    NSString *delegateGetterKey = NSStringFromSelector(getter);
    if (!self.fb_multipleDelegate[delegateGetterKey]) {
        objc_property_t prop = class_getProperty(self.class, delegateGetterKey.UTF8String);
        MBPropertyDescriptor *property = [MBPropertyDescriptor descriptorWithProperty:prop];
        if (property.isStrong) {
            // strong property
            MBMultipleDelegate *strongDelegates = [MBMultipleDelegate strongDelegate];
            strongDelegates.parentObject = self;
            self.fb_multipleDelegate[delegateGetterKey] = strongDelegates;
        } else {
            // weak property
            MBMultipleDelegate *weakDelegates = [MBMultipleDelegate weakDelegate];
            weakDelegates.parentObject = self;
            self.fb_multipleDelegate[delegateGetterKey] = weakDelegates;
        }
    }
    
    // 避免为某个 class 重复替换同一个方法的实现
    if (!self.fb_methodsReplacedClasses) {
        self.fb_methodsReplacedClasses = [NSMutableSet set];
    }
    
    Class targetClass = [self class];
    SEL originDelegateSetter = setterWithGetter(getter);

    NSString *classAndMethodIdentifier = [NSString stringWithFormat:@"%@_%@", NSStringFromClass(targetClass), delegateGetterKey];
    
    if (![fb_methodsReplacedClasses containsObject:classAndMethodIdentifier]) {
        
        [fb_methodsReplacedClasses addObject:classAndMethodIdentifier];
        
        [RSSwizzle swizzleInstanceMethod:originDelegateSetter inClass:targetClass newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
            return ^(NSObject *target, id delegate){
                
                void (*originSelectorIMP)(id, SEL, id);
                originSelectorIMP = (__typeof(originSelectorIMP))[swizzleInfo getOriginalImplementation];
                
                // 保护的原因：要自己加一下 class 的判断保护，保证只有 self.class 及 self.subclass 才执行。self.superclass不执行
                if (!target.fb_multipleDelegateEnabled || target.class != targetClass) {
                    originSelectorIMP(target, originDelegateSetter, delegate);
                    return;
                }
                
                MBMultipleDelegate *delegates = target.fb_multipleDelegate[delegateGetterKey];
                
                if (!delegate) {
                    // 对应 setDelegate:nil，表示清理所有的 delegate
                    [delegates removeAllDelegates];
                    target.fb_delegateSelf = NO;
                    return;
                }
                
                if (delegate != delegates) {// 过滤掉容器自身，避免把 delegates 传进去 delegates 里，导致死循环
                    [delegates addDelegate:delegate];
                }
                
                // 将类似 textView.delegate = textView 的情况标志起来，避免产生循环调用
                target.fb_delegateSelf = [delegates.delegates fb_containsPointer:(__bridge void * _Nullable)(target)];
                
                originSelectorIMP(target, originDelegateSetter, nil);// 先置为 nil 再设置 delegates，从而避免部分情况多代理不相应
                originSelectorIMP(target, originDelegateSetter, delegates);// 不管外面将什么 object 传给 setDelegate:，最终实际上传进去的都是 MBMultipleDelegate 容器

            };
        } mode:RSSwizzleModeAlways key:"app.multiple.delegate"];
    }
    
    // 如果原来已经有 delegate，则将其加到新建的容器里
    BeginIgnoreClangWarning("-Warc-performSelector-leaks")
    id originDelegate = [self performSelector:getter];
    if (originDelegate && originDelegate != self.fb_multipleDelegate[delegateGetterKey]) {
        [self performSelector:originDelegateSetter withObject:originDelegate];
    }
    EndIgnoreClangWarning
}

- (void)fb_removeDelegate:(id)delegate
{
    if (!self.fb_multipleDelegateEnabled) {
        return;
    }
    NSMutableArray<NSString *> *delegateGetters = [[NSMutableArray alloc] init];
    [self.fb_multipleDelegate enumerateKeysAndObjectsUsingBlock:^(NSString *key, MBMultipleDelegate *obj, BOOL *stop) {
        BOOL removeSucceed = [obj removeDelegate:delegate];
        if (removeSucceed) {
            [delegateGetters addObject:key];
        }
    }];
    if (delegateGetters.count > 0) {
        for (NSString *getterString in delegateGetters) {
            [self refreshDelegateWithGetter:NSSelectorFromString(getterString)];
        }
    }
}

- (void)refreshDelegateWithGetter:(SEL)getter
{
    SEL originSetterSEL = [self newSetterWithGetter:getter];
    BeginIgnoreClangWarning("-Warc-performSelector-leaks")
    id originDelegate = [self performSelector:getter];
    [self performSelector:originSetterSEL withObject:nil];// 先置为 nil 再设置 delegates，从而避免有的代理未响应
    [self performSelector:originSetterSEL withObject:originDelegate];
    EndIgnoreClangWarning
}

// 根据 delegate property 的 getter，得到 MBMultipleDelegate 为它的 setter 创建的新 setter 方法，最终交换原方法，因此利用这个方法返回的 SEL，可以调用到原来的 delegate property setter 的实现
- (SEL)newSetterWithGetter:(SEL)getter
{
    return NSSelectorFromString([NSString stringWithFormat:@"fb_%@", NSStringFromSelector(setterWithGetter(getter))]);
}

@end

@interface MBMultipleDelegate ()

@property(nonatomic, strong, readwrite) NSPointerArray *delegates;

@end

@implementation MBMultipleDelegate

+ (instancetype)weakDelegate {
    MBMultipleDelegate *delegates = [[MBMultipleDelegate alloc] init];
    delegates.delegates = [NSPointerArray weakObjectsPointerArray];
    return delegates;
}

+ (instancetype)strongDelegate {
    MBMultipleDelegate *delegates = [[MBMultipleDelegate alloc] init];
    delegates.delegates = [NSPointerArray strongObjectsPointerArray];
    return delegates;
}

- (void)addDelegate:(id)delegate {
    if (![self containsDelegate:delegate] && delegate != self) {
        [self.delegates addPointer:(__bridge void *)delegate];
    }
}

- (BOOL)removeDelegate:(id)delegate {
    NSUInteger index = [self.delegates fb_indexOfPointer:(__bridge void *)delegate];
    if (index != NSNotFound) {
        [self.delegates removePointerAtIndex:index];
        return YES;
    }
    return NO;
}

- (void)removeAllDelegates {
    for (NSInteger i = self.delegates.count - 1; i >= 0; i--) {
        [self.delegates removePointerAtIndex:i];
    }
}

- (BOOL)containsDelegate:(id)delegate {
    return [self.delegates fb_containsPointer:(__bridge void *)delegate];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *result = [super methodSignatureForSelector:aSelector];
    if (result) {
        return result;
    }
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        result = [delegate methodSignatureForSelector:aSelector];
        if (result && [delegate respondsToSelector:aSelector]) {
            return result;
        }
    }
    
    return NSMethodSignature.fb_avoidExceptionSignature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = anInvocation.selector;
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:selector]) {
            [anInvocation invokeWithTarget:delegate];
        }
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if (class_respondsToSelector(self.class, aSelector)) {
            return YES;
        }
        
        BOOL delegateCanRespondToSelector = [delegate isKindOfClass:self.class] ? [delegate respondsToSelector:aSelector] : class_respondsToSelector(((NSObject *)delegate).class, aSelector);
        
        // 不支持 self.delegate = self 的写法，会引发死循环，有这种需求的场景建议在 self 内部创建一个对象专门用于 delegate 的响应。
        BOOL isDelegateSelf = ((NSObject *)delegate).fb_delegateSelf;
        if (delegateCanRespondToSelector && !isDelegateSelf) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Overrides

- (BOOL)isKindOfClass:(Class)aClass {
    BOOL result = [super isKindOfClass:aClass];
    if (result) return YES;
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate isKindOfClass:aClass]) return YES;
    }
    
    return NO;
}

- (BOOL)isMemberOfClass:(Class)aClass {
    BOOL result = [super isMemberOfClass:aClass];
    if (result) return YES;
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate isMemberOfClass:aClass]) return YES;
    }
    
    return NO;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    BOOL result = [super conformsToProtocol:aProtocol];
    if (result) return YES;
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate conformsToProtocol:aProtocol]) return YES;
    }
    
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, parentObject is %@, %@", [super description], self.parentObject, self.delegates];
}

@end
