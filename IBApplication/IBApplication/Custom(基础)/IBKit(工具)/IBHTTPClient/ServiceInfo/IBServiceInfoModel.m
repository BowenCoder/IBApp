//
//  IBServiceInfoModel.m
//  IBApplication
//
//  Created by Bowen on 2019/12/12.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBServiceInfoModel.h"
#import "NSDictionary+Ext.h"
#import "IBMacros.h"

@interface IBServiceInfoModel ()

@property (nonatomic, copy) NSString *version;
@property (nonatomic, strong) NSMutableDictionary *serviceUrls;
@property (nonatomic, strong) NSMutableDictionary *serviceSwitchs;

@end

@implementation IBServiceInfoModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.serviceUrls = [NSMutableDictionary dictionary];
        self.serviceSwitchs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSDictionary *)refreshServiceInfo:(NSDictionary *)dict
{
    NSString *version = [dict mb_stringForKey:@"version"];
    NSArray *servers  = [dict mb_arrayForKey:@"servers"];
    NSArray *switches = [dict mb_arrayForKey:@"switches"];
    
    if (!kIsEmptyString(version)) {
        self.version = version;
    }
    
    for (NSDictionary *item in servers) {
        [self.serviceUrls mb_setObject:item[@"url"] forKey:item[@"key"]];
    }
    
    for (NSDictionary *item in switches) {
        [self.serviceSwitchs mb_setObject:item[@"switch"] forKey:item[@"name"]];
    }
    
    NSMutableDictionary *serviceInfo = [NSMutableDictionary dictionary];
    [serviceInfo mb_setObject:self.serviceSwitchs forKey:@"switches"];
    [serviceInfo mb_setObject:self.serviceUrls forKey:@"servers"];
    [serviceInfo mb_setObject:self.version forKey:@"version"];
    
    return serviceInfo;
}

- (NSString *)urlFromKey:(NSString *)key
{
    return [self.serviceUrls mb_stringForKey:key];
}

- (BOOL)switchFromKey:(NSString *)key
{
    return [[self.serviceSwitchs mb_numberForKey:key] boolValue];
}

@end
