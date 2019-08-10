//
//  MBGradientView.h
//  IBApplication
//
//  Created by Bowen on 2019/8/10.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MBGradientStyle) {
    MBGradientTopToBottom = 0,
    MBGradientLeftToRight,
    MBGradientLeftTopToRightBottom,
    MBGradientLeftBottomToRightTop,
};

NS_ASSUME_NONNULL_BEGIN

@interface MBGradientView : UIView

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *middleColor;
@property (nonatomic, strong) UIColor *endColor;
@property (nonatomic, assign) MBGradientStyle style;

- (instancetype)initWithStyle:(MBGradientStyle)style;

@end

NS_ASSUME_NONNULL_END
