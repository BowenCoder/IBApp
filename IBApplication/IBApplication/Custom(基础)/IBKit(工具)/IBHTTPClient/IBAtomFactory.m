//
//  IBAtomFactory.m
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBAtomFactory.h"

@implementation IBAtomFactory

+ (instancetype)sharedInstance
{
    static IBAtomFactory *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[IBAtomFactory alloc] init];
    });
    return instance;
}

- (void)clear
{
    
}

@end
