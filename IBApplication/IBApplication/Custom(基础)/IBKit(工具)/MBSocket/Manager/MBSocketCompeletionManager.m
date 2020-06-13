//
//  MBSocketCompeletionManager.m
//  IBApplication
//
//  Created by Bowen on 2020/6/12.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketCompeletionManager.h"

@interface MBSocketCompeletionManager ()

@property (nonatomic, strong) NSMutableDictionary *compeletionDict;
@property (nonatomic, strong) dispatch_semaphore_t lock;

@end

@implementation MBSocketCompeletionManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.compeletionDict = [NSMutableDictionary dictionary];
        self.lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)setCompeletion:(MBSocketRspCallback)compeletion forKey:(NSString *)key
{
    if (!compeletion || !key) {
        return;
    }
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    [self.compeletionDict setObject:compeletion forKey:key];
    dispatch_semaphore_signal(self.lock);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.messageTimeout+1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeCompeletionForKey:key];
    });
}

- (MBSocketRspCallback)compeletionForKey:(NSString *)key
{
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    MBSocketRspCallback compeletion = [self.compeletionDict objectForKey:key];
    dispatch_semaphore_signal(self.lock);
    return compeletion;
}

- (void)removeCompeletionForKey:(NSString *)key
{
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    [self.compeletionDict removeObjectForKey:key];
    dispatch_semaphore_signal(self.lock);
}

- (void)registerMessageCompeletion:(MBSocketRspCallback)compeletion key:(NSString *)key target:(id)target
{
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    NSMapTable *mapTable = [self.compeletionDict objectForKey:key];
    if (!mapTable) {
        mapTable = [NSMapTable weakToStrongObjectsMapTable];
    }
    [mapTable setObject:compeletion forKey:target];
    [self.compeletionDict setObject:mapTable forKey:key];
    dispatch_semaphore_signal(self.lock);
}

- (NSArray *)registerMessageCompeletionsForKey:(NSString *)key
{
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    NSMapTable *mapTable = [self.compeletionDict objectForKey:key];
    NSArray *compeletions = NSAllMapTableValues(mapTable);
    dispatch_semaphore_signal(self.lock);
    return compeletions;
}

@end
