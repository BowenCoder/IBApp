//
//  MBPluginCenterService.m
//  IBApplication
//
//  Created by Bowen on 2019/8/13.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBPluginCenterService.h"
#import "MBLogger.h"

@interface MBPluginCenterService ()

@property (nonatomic, strong) NSRecursiveLock *serviceLock;
@property (nonatomic, strong) NSMutableDictionary *classDict;
@property (nonatomic, strong) NSMutableDictionary *instanceDict;

@end

@implementation MBPluginCenterService

- (void)registerProtocol:(Protocol *)service implClass:(Class)implClass
{
    NSParameterAssert(service);
    NSParameterAssert(implClass);
    
    if (![implClass conformsToProtocol:service]) {
        MBLogE(@"%@ module does not comply with %@ protocol", NSStringFromClass(implClass), NSStringFromProtocol(service));
        
#if DEBUG
        @throw [NSString stringWithFormat:@"%@ module does not comply with %@ protocol", NSStringFromClass(implClass), NSStringFromProtocol(service)];
#endif
        
        return;
    }
    
    [self.serviceLock lock];
    
    if ([self checkValidService:service]) {
        MBLogE(@"%@ protocol has been registed", NSStringFromProtocol(service));
        
#if DEBUG
        @throw [NSString stringWithFormat:@"%@ protocol has been registed", NSStringFromProtocol(service)];
#endif

    } else {
        
        NSString *key   = NSStringFromProtocol(service);
        NSString *value = NSStringFromClass(implClass);
        
        if (key.length > 0 && value.length > 0) {
            [self.classDict setObject:value forKey:key];
        }
    }
    
    [self.serviceLock unlock];
}

- (void)registerProtocol:(Protocol *)service implInstance:(id)implInstance
{
    NSString *serviceString = NSStringFromProtocol(service);
    
    if (serviceString.length > 0 && implInstance) {
        [self.serviceLock lock];
        [self.instanceDict setObject:implInstance forKey:serviceString];
        [self.serviceLock unlock];
    }
}

- (id)service:(Protocol *)protocol
{
    [self.serviceLock lock];
    id service = [self service:protocol newInstance:NO];
    [self.serviceLock unlock];
    return service;
}

- (void)removeService:(Protocol *)service
{
    [self.serviceLock lock];

    if (![self checkValidService:service]) {
        MBLog(@"%@ protocol does not been registed", NSStringFromProtocol(service));
    } else {
        NSString *serviceStr = NSStringFromProtocol(service);
        [self.instanceDict removeObjectForKey:serviceStr];
        [self.classDict removeObjectForKey:serviceStr];
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

- (id)service:(Protocol *)service newInstance:(BOOL)newInstance
{
    id implInstance = nil;
    
    NSString *serviceStr = NSStringFromProtocol(service);
    
    if (!newInstance) {
        id protocolImpl = [self.instanceDict objectForKey:serviceStr];
        if (protocolImpl) {
            return protocolImpl;
        }
    }
    
    if (![self checkValidService:service]) {
        MBLogE(@"%@ protocol does not been registed", NSStringFromProtocol(service));
        return nil;
    }
    
    Class implClass = [self serviceImplClass:service];
    
    implInstance = [[implClass alloc] init];
    
    if (!newInstance) {
        [self.instanceDict setObject:implInstance forKey:serviceStr];
    }
    
    return implInstance;
}

- (BOOL)checkValidService:(Protocol *)service
{
    NSString *serviceImpl = [self.classDict objectForKey:NSStringFromProtocol(service)];
    if (serviceImpl.length > 0) {
        return YES;
    }
    return NO;
}

- (Class)serviceImplClass:(Protocol *)service
{
    NSString *serviceImpl = [self.classDict objectForKey:NSStringFromProtocol(service)];
    if (serviceImpl.length > 0) {
        return NSClassFromString(serviceImpl);
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
