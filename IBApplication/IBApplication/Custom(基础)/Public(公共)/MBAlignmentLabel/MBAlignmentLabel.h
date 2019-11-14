//
//  MBAlignmentLabel.h
//  IBApplication
//
//  Created by Bowen on 2019/8/12.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MBTextAlignment) {
    MBTextAlignmentDefault = 0,  // 默认系统方法
    MBTextAlignmentLeftTop = 1,  // 左上
    MBTextAlignmentLeftCenter,   // 左中
    MBTextAlignmentLeftBottom,   // 左下
    MBTextAlignmentRightTop,     // 右上
    MBTextAlignmentRightCenter,  // 右中
    MBTextAlignmentRightBottom,  // 右下
    MBTextAlignmentCenterTop,    // 中上
    MBTextAlignmentCenter,       // 中心
    MBTextAlignmentCenterBottom, // 中下
};

NS_ASSUME_NONNULL_BEGIN

@interface MBAlignmentLabel : UILabel

@property (nonatomic, assign) MBTextAlignment textAlign;
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;

@end

NS_ASSUME_NONNULL_END
