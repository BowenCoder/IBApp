//
//  MBPluginCenter.m
//  IBApplication
//
//  Created by Bowen on 2019/8/13.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBPluginCenter.h"

@interface MBPluginCenter ()

@property (nonatomic, strong) NSMutableDictionary <NSString *, id<MBPluginCenterProtocol>> *plugins;
@property (nonatomic, strong) MBPluginCenterService *centerService;

@end

@implementation MBPluginCenter

- (void)registerPlugin:(id<MBPluginCenterProtocol>)module
{
    if ([NSThread isMainThread]) {
        [self.plugins setObject:module forKey:NSStringFromClass(module.class)];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.plugins setObject:module forKey:NSStringFromClass(module.class)];
        });
    }
}

- (void)unregisterPlugin:(id<MBPluginCenterProtocol>)module
{
    if ([NSThread isMainThread]) {
        [self.plugins removeObjectForKey:NSStringFromClass(module.class)];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.plugins removeObjectForKey:NSStringFromClass(module.class)];
        });
    }
}

- (id<MBPluginCenterServiceProtocol>)service
{
    return self.centerService;
}

- (id)serviceInstance:(Protocol *)protocol
{
    return [self.centerService service:protocol];
}

- (void)removeService:(Protocol *)protocol
{
    [self.centerService removeService:protocol];
}

- (void)clearService
{
    [self.centerService clear];
}

#pragma mark - MBPluginCenterProtocol

- (void)viewDidLoad:(MBContext *)context
{
    [self performSelectorInPlugins:_cmd context:context isContextValided:YES];
}

- (void)viewWillAppear:(MBContext *)context
{
    [self performSelectorInPlugins:_cmd context:context isContextValided:YES];
}

- (void)viewDidAppear:(MBContext *)context
{
    [self performSelectorInPlugins:_cmd context:context isContextValided:YES];
}

- (void)viewWillDisappear:(MBContext *)context
{
    [self performSelectorInPlugins:_cmd context:context isContextValided:YES];
}

- (void)viewDidDisappear:(MBContext *)context
{
    [self performSelectorInPlugins:_cmd context:context isContextValided:YES];
}

- (void)pluginWillDealloc:(MBContext *)context
{
    [self performSelectorInPlugins:_cmd context:context isContextValided:YES];
}

- (void)didReceiveMemoryWarning
{
    [self performSelectorInPlugins:_cmd context:nil isContextValided:NO];
}

- (void)didEnterBackground
{
    [self performSelectorInPlugins:_cmd context:nil isContextValided:NO];
}

- (void)didBecomeActive
{
    [self performSelectorInPlugins:_cmd context:nil isContextValided:NO];
}

- (void)performSelectorInPlugins:(SEL)selector context:(id)context isContextValided:(BOOL)isContextValided
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    for (id<MBPluginCenterProtocol> obj in self.plugins) {
        if ([obj respondsToSelector:selector]) {
            if (isContextValided) {
                [obj performSelector:selector withObject:context];
            } else {
                [obj performSelector:selector];
            }
        }
    }
#pragma clang diagnostic pop
}

#pragma mark - getter

- (NSMutableDictionary<NSString *,id<MBPluginCenterProtocol>> *)plugins {
    if(!_plugins){
        _plugins = [NSMutableDictionary dictionary];
    }
    return _plugins;
}

- (MBPluginCenterService *)centerService {
    if(!_centerService){
        _centerService = [[MBPluginCenterService alloc] init];
    }
    return _centerService;
}

@end
