//
//  IBNaviConfig.m
//  IBApplication
//
//  Created by Bowen on 2018/7/14.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBNaviConfig.h"

@implementation IBNaviConfig

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _alpha = 1.0;
        _hidden = NO;
        _translucent = YES;
        _transparent = NO;
        _barStyle = UIBarStyleDefault;
        _backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end
