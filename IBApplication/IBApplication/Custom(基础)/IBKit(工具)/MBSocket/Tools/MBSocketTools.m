//
//  MBSocketTools.m
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketTools.h"

@implementation MBSocketTools

+ (dispatch_queue_t)socketQueue
{
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.bowen.persistent.socket", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

@end
