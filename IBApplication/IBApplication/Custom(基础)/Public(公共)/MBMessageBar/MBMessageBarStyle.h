//
//  MBMessageBarStyle.h
//  IBApplication
//
//  Created by Bowen on 2020/1/6.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MBMessageBarStyleType) {
    MBMessageBarStyleTypeCustom  = 0,
    MBMessageBarStyleTypeError   = 1,
    MBMessageBarStyleTypeSuccess = 2,
    MBMessageBarStyleTypeWarning = 3,
    MBMessageBarStyleTypeInfo    = 4
};

typedef NS_ENUM(NSInteger, MBMessageBarPosition) {
    MBMessageBarPositionDefault = 0, // 屏幕顶部
    MBMessageBarPositionBelowStatusBar = 1, // 状态栏下面
};

@protocol MBMessageBarStyleProtocol <NSObject>

@property (nullable, nonatomic, strong) UIImage *customIconImage;

@property (nonatomic, strong) UIColor *customBackgroundColor;

- (UIColor *)backgroundColorForMessageType:(MBMessageBarStyleType)type;

- (UIImage *)iconImageForMessageType:(MBMessageBarStyleType)type;

@optional

- (UIFont *)titleFontForMessageType:(MBMessageBarStyleType)type;

- (UIFont *)messageFontForMessageType:(MBMessageBarStyleType)type;

- (UIColor *)titleColorForMessageType:(MBMessageBarStyleType)type;

- (UIColor *)messageColorForMessageType:(MBMessageBarStyleType)type;

@end


@interface MBMessageBarStyle : NSObject <MBMessageBarStyleProtocol>

@end

NS_ASSUME_NONNULL_END
