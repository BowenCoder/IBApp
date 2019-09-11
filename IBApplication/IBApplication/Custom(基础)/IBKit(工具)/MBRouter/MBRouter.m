//
//  MBRouter.m
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBRouter.h"
#import "IBMacros.h"

static NSString *const kRouterDefaultPName  = @"pName";
static NSString *const kRouterDefaultScheme = @"scheme";

@interface MBRouter()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *schemeMapper;

@end


@implementation MBRouter

+ (instancetype)defaultRouter
{
    static MBRouter *_router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!_router) {
            _router = [[MBRouter alloc] init];
        }
    });
    
    return _router;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _schemeMapper = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerWithScheme:(NSString *)scheme handler:(Class<MBRouterProtocol>)handler
{
    [self registerWithScheme:scheme pName:kRouterDefaultScheme handler:handler];
}

- (void)registerWithPName:(nullable NSString *)pName handler:(Class<MBRouterProtocol>)handler
{
    [self registerWithScheme:kRouterDefaultPName pName:pName handler:handler];
}

- (void)registerWithScheme:(NSString *)scheme pName:(nullable NSString *)pName handler:(Class<MBRouterProtocol>)handler
{
    if (!scheme.length || !handler) {
        return;
    }
    
    if (!pName.length) {
        pName = kRouterDefaultPName;
    }
    pName = [pName lowercaseString];
    
    @synchronized (_schemeMapper) {
        if([self handlerForScheme:scheme pName:pName enableFuzzyMatch:NO]) {
            NSAssert(NO, @"警告：Scheme相同的情况下pName必须唯一！！！");
            return;
        }
        
        NSMutableArray *someArray = [_schemeMapper valueForKey:scheme];
        if (!someArray) {
            someArray = [NSMutableArray array];
        }
        [someArray addObject:@{pName : NSStringFromClass(handler)}];
        [_schemeMapper setValue:someArray forKey:scheme];
    }
}

- (void)unregisterWithScheme:(NSString *)scheme pName:(nullable NSString *)pName
{
    if (!scheme.length) {
        scheme = kRouterDefaultScheme;
    }
    if (!pName.length) {
        pName = kRouterDefaultPName;
    }
    pName = [pName lowercaseString];
    
    @synchronized (_schemeMapper) {
        NSMutableArray *handlers = [_schemeMapper valueForKey:scheme];
        for (NSDictionary *tempDict in handlers) {
            NSString *handler = [tempDict valueForKey:pName];
            if (handler) {
                [handlers removeObject:tempDict];
                if (handlers.count == 0) {
                    [_schemeMapper removeObjectForKey:scheme];
                }
                break;
            }
        }
    }
}

- (BOOL)open:(NSString *)url target:(__kindof UIViewController *)target
{
    return [self open:url target:target responseHandler:nil];
}

- (BOOL)open:(NSString *)url target:(nullable __kindof UIViewController *)target responseHandler:(MBRouterResultCallback)responseHandler
{
    return [self open:url application:nil annotation:nil target:target responseHandler:responseHandler];
}

- (BOOL)open:(NSString *)url application:(UIApplication *)application annotation:(id)annotation target:(__kindof UIViewController *)target
{
    return [self open:url application:application annotation:annotation target:target responseHandler:nil];
}

- (BOOL)open:(NSString *)url application:(nullable UIApplication *)application annotation:(nullable id)annotation target:(nullable __kindof UIViewController *)target responseHandler:(nullable MBRouterResultCallback)responseHandler
{
    if (kIsEmptyString(url)) return NO;
    
    MBRouterRequest *request = [MBRouterRequest requestWithURLString:url resultCallback:responseHandler];
    
    @synchronized (_schemeMapper) {
        Class<MBRouterProtocol> handler = [self handlerForScheme:request.scheme pName:request.pName enableFuzzyMatch:YES];
        
        // 如果pName没有注册，使用scheme默认的router
        if (!handler && request.pName.length) {
            handler = [self handlerForScheme:request.scheme pName:nil enableFuzzyMatch:YES];
        }
        
        if (handler) {
            if (!target) {
                target = [self topViewController];
            }
            
            if ([handler respondsToSelector:@selector(openRequest:application:annotation:target:)]) {
                return [handler openRequest:request application:application annotation:annotation target:target];
            }
        }
    }
    
    return NO;
}

- (Class<MBRouterProtocol>)handlerForScheme:(NSString *)scheme pName:(nullable NSString *)pName enableFuzzyMatch:(BOOL)enableFuzzyMatch
{
    if (!scheme.length) {
        return nil;
    }
    
    if (!pName.length) {
        pName = kRouterDefaultPName;
    }
    
    @synchronized (_schemeMapper) {
        __block NSString *keyPath = [NSString stringWithFormat:@"%@.%@", scheme, pName];
        NSMutableArray *handlers = [[_schemeMapper valueForKeyPath:keyPath] mutableCopy];
        [handlers removeObjectIdenticalTo:[NSNull null]];
        NSString *schemeHandler = [handlers lastObject];
        
        // 需要支持模糊scheme：例如注册的时候写wb，但是使用的时候传进来 wb123
        if (!schemeHandler && enableFuzzyMatch) {
            keyPath = nil;
            [_schemeMapper.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([scheme hasPrefix:obj]) {
                    keyPath = [NSString stringWithFormat:@"%@.%@", obj, pName];
                    *stop = YES;
                }
            }];
            
            if (keyPath) {
                handlers = [[_schemeMapper valueForKeyPath:keyPath] mutableCopy];
                [handlers removeObjectIdenticalTo:[NSNull null]];
                schemeHandler = [handlers lastObject];
            }
        }
        
        if (schemeHandler) {
            return NSClassFromString(schemeHandler);
        }
    }
    return nil;
}

- (UIViewController *)topViewController
{
    UIViewController *target = nil;
    
    target = [self topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    
    if (!target) {
        return  nil;
    }
    
    while (target.presentedViewController) {
        target = [self topViewController:target.presentedViewController];
    }
    
    return target;
}

- (UIViewController *)topViewController:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UINavigationController class]])
    {
        return [self topViewController:[(UINavigationController *)vc topViewController]];
    }
    else if ([vc isKindOfClass:[UITabBarController class]])
    {
        return [self topViewController:[(UITabBarController *)vc selectedViewController]];
    }
    else {
        return vc;
    }
    
    return nil;
}



@end
