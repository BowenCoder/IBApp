//
//  MBMessageBarStyle.m
//  IBApplication
//
//  Created by Bowen on 2020/1/6.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBMessageBarStyle.h"

@implementation MBMessageBarStyle
@synthesize customIconImage, customBackgroundColor;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.customIconImage = nil;
        self.customBackgroundColor = [UIColor darkGrayColor];
    }
    return self;
}

- (UIColor *)backgroundColorForMessageType:(MBMessageBarStyleType)type
{
    UIColor *backgroundColor = nil;
    switch (type) {
        case MBMessageBarStyleTypeCustom:
            backgroundColor = self.customBackgroundColor;
            break;
        case MBMessageBarStyleTypeError:
            backgroundColor = [UIColor colorWithRed:255.f/255.f green:91.f/255.f blue:65.f/255.f alpha:1.f];
            break;
        case MBMessageBarStyleTypeSuccess:
            backgroundColor = [UIColor colorWithRed:31.f/255.f green:177.f/255.f blue:138.f/255.f alpha:1.f];
            break;
        case MBMessageBarStyleTypeWarning:
            backgroundColor = [UIColor colorWithRed:255.f/255.f green:134.f/255.f blue:0.f/255.f alpha:1.f];
            break;
        case MBMessageBarStyleTypeInfo:
            backgroundColor = [UIColor colorWithRed:75.f/255.f green:107.f/255.f blue:122.f/255.f alpha:1.f];
            break;
        default:
            break;
    }
    return backgroundColor;
}

- (UIImage *)iconImageForMessageType:(MBMessageBarStyleType)type
{
    UIImage *iconImage = nil;
    switch (type) {
        case MBMessageBarStyleTypeCustom:
            iconImage = self.customIconImage;
            break;
        case MBMessageBarStyleTypeError:
            iconImage = [UIImage imageNamed:@"MBMessageBar.bundle/error.png"];
            break;
        case MBMessageBarStyleTypeSuccess:
            iconImage = [UIImage imageNamed:@"MBMessageBar.bundle/success.png"];
            break;
        case MBMessageBarStyleTypeWarning:
            iconImage = [UIImage imageNamed:@"MBMessageBar.bundle/warning.png"];
            break;
        case MBMessageBarStyleTypeInfo:
            iconImage = [UIImage imageNamed:@"MBMessageBar.bundle/info.png"];
            break;
        default:
            break;
    }
    return iconImage;
}

@end
