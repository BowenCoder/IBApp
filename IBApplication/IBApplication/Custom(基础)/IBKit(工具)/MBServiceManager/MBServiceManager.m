//
//  MBServiceManager.m
//  IBApplication
//
//  Created by Bowen on 2019/9/11.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBServiceManager.h"
#import "MBLogger.h"

@interface MBServiceManager ()

@property (nonatomic, strong) NSRecursiveLock *serviceLock;
@property (nonatomic, strong) NSMutableDictionary *classDict;
@property (nonatomic, strong) NSMutableDictionary *instanceDict;

@end

@implementation MBServiceManager

+ (instancetype)sharedManager
{
    static MBServiceManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MBServiceManager alloc] init];
    });
    return manager;
}

- (void)registerProtocol:(Protocol *)protocol implClass:(Class)implClass
{
    NSParameterAssert(protocol);
    NSParameterAssert(implClass);
    
    if (![implClass conformsToProtocol:protocol]) {
        MBLogE(@"%@ module does not comply with %@ protocol", NSStringFromClass(implClass), NSStringFromProtocol(protocol));
        
#if DEBUG
        @throw [NSString stringWithFormat:@"%@ module does not comply with %@ protocol", NSStringFromClass(implClass), NSStringFromProtocol(protocol)];
#endif
        
        return;
    }
    
    [self.serviceLock lock];
    
    if ([self checkValidService:protocol]) {
        MBLogE(@"%@ protocol has been registed", NSStringFromProtocol(protocol));
        
#if DEBUG
        @throw [NSString stringWithFormat:@"%@ protocol has been registed", NSStringFromProtocol(protocol)];
#endif
        
    } else {
        
        NSString *key   = NSStringFromProtocol(protocol);
        NSString *value = NSStringFromClass(implClass);
        
        if (key.length > 0 && value.length > 0) {
            [self.classDict setObject:value forKey:key];
        }
    }
    
    [self.serviceLock unlock];
}

- (void)registerProtocol:(Protocol *)protocol implInstance:(id)implInstance
{
    NSString *protocolString = NSStringFromProtocol(protocol);
    
    if (protocolString.length > 0 && implInstance) {
        [self.serviceLock lock];
        [self.instanceDict setObject:implInstance forKey:protocolString];
        [self.serviceLock unlock];
    }
}

- (id)serviceInstance:(Protocol *)protocol
{
    [self.serviceLock lock];
    id service = [self service:protocol newInstance:NO];
    [self.serviceLock unlock];
    return service;
}

- (void)removeInstance:(Protocol *)protocol
{
    [self.serviceLock lock];
    
    if (![self checkValidService:protocol]) {
        MBLog(@"%@ protocol does not been registed", NSStringFromProtocol(protocol));
    } else {
        NSString *protocolStr = NSStringFromProtocol(protocol);
        [self.instanceDict removeObjectForKey:protocolStr];
    }
    
    [self.serviceLock unlock];
}

- (void)removeService:(Protocol *)protocol
{
    [self.serviceLock lock];
    
    if (![self checkValidService:protocol]) {
        MBLog(@"%@ protocol does not been registed", NSStringFromProtocol(protocol));
    } else {
        NSString *protocolStr = NSStringFromProtocol(protocol);
        [self.instanceDict removeObjectForKey:protocolStr];
        [self.classDict removeObjectForKey:protocolStr];
    }
    
    [self.serviceLock unlock];
}

- (void)clear
{
    [self.serviceLock lock];
    
    [self.classDict removeAllObjects];
    [self.instanceDict removeAllObjects];
    
    [self.serviceLock unlock];
}

#pragma mark - 私有

- (id)service:(Protocol *)protocol newInstance:(BOOL)newInstance
{
    id implInstance = nil;
    
    NSString *protocolStr = NSStringFromProtocol(protocol);
    
    if (!newInstance) {
        id protocolImpl = [self.instanceDict objectForKey:protocolStr];
        if (protocolImpl) {
            return protocolImpl;
        }
    }
    
    if (![self checkValidService:protocol]) {
        MBLogE(@"%@ protocol does not been registed", NSStringFromProtocol(protocol));
        return nil;
    }
    
    Class implClass = [self serviceImplClass:protocol];
    
    implInstance = [[implClass alloc] init];
    
    if (!newInstance) {
        [self.instanceDict setObject:implInstance forKey:protocolStr];
    }
    
    return implInstance;
}

- (BOOL)checkValidService:(Protocol *)protocol
{
    NSString *protocolImpl = [self.classDict objectForKey:NSStringFromProtocol(protocol)];
    if (protocolImpl.length > 0) {
        return YES;
    }
    return NO;
}

- (Class)serviceImplClass:(Protocol *)protocol
{
    NSString *protocolImpl = [self.classDict objectForKey:NSStringFromProtocol(protocol)];
    if (protocolImpl.length > 0) {
        return NSClassFromString(protocolImpl);
    }
    return nil;
}

#pragma mark - getter

- (NSMutableDictionary *)classDict {
    if(!_classDict){
        _classDict = [NSMutableDictionary dictionary];
    }
    return _classDict;
}

- (NSMutableDictionary *)instanceDict {
    if(!_instanceDict){
        _instanceDict = [NSMutableDictionary dictionary];
    }
    return _instanceDict;
}

- (NSRecursiveLock *)serviceLock {
    if(!_serviceLock){
        _serviceLock = [[NSRecursiveLock alloc] init];
    }
    return _serviceLock;
}


@end
