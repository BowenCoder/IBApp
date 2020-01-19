//
//  NSObject+TrackData.m
//  IBApplication
//
//  Created by Bowen on 2020/1/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "NSObject+TrackData.h"
#import <objc/runtime.h>

@implementation NSObject (TrackData)

- (void)setIgnoreTracking:(BOOL)ignoreTracking
{
    objc_setAssociatedObject(self, @selector(ignoreTracking), @(ignoreTracking), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)ignoreTracking
{
    return [objc_getAssociatedObject(self, @selector(ignoreTracking)) boolValue];
}

- (void)setTrackingData:(NSDictionary *)trackingData
{
    objc_setAssociatedObject(self, @selector(trackingData), trackingData, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *)trackingData
{
    return objc_getAssociatedObject(self, @selector(trackingData));
}

@end
