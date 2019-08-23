//
//  MBImageView.m
//  IBApplication
//
//  Created by Bowen on 2019/8/23.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBImageView.h"

@implementation MBImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

@end
