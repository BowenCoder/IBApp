//
//  MBTabBarBadge.m
//  IBApplication
//
//  Created by Bowen on 2018/7/19.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBTabBarBadge.h"

@implementation MBTabBarBadge

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor redColor];
    self.textColor = [UIColor whiteColor];
    self.font = [UIFont boldSystemFontOfSize:10];
    self.textAlignment = NSTextAlignmentCenter;
    self.clipsToBounds = YES;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.layer.cornerRadius = self.frame.size.height/2.0;
}

- (void)setBadgeValue:(NSString *)badgeValue {
    
    _badgeValue = badgeValue;
    
    if (badgeValue.integerValue != 1) {
        self.text = badgeValue;
    }
    
    if (badgeValue.integerValue) { // 是不为0的数字
        self.hidden = NO; // 先取消隐藏
        if (badgeValue.integerValue > 99) {
            self.text = @"99+";
        }
    } else {
        if (!badgeValue.length || [badgeValue isEqualToString:@"0"]) { // 不存在的空串
            self.hidden = YES;
        }
    }
    
    CGFloat width = 27;
    CGFloat height = 16;
    if (badgeValue.length == 1) {
        width = 16;
    }
    if (badgeValue.length == 2) {
        width = 24;
    }
    if (badgeValue.length == 3) {
        width = 27;
    }
    if (badgeValue.integerValue == 1) {
        width = 8;
        height = 8;
    }
    
    CGRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = height;
    self.frame = frame;
}


@end
