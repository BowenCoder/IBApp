//
//  MBButton.h
//  IBApplication
//
//  Created by Bowen on 2019/8/13.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 图片和文字布局类型
 */
typedef NS_ENUM(NSUInteger, MBButtonAlignment) {
    MBButtonAlignmentTop, // image在上，label在下
    MBButtonAlignmentLeft, // image在左，label在右
    MBButtonAlignmentBottom, // image在下，label在上
    MBButtonAlignmentRight // image在右，label在左
};

NS_ASSUME_NONNULL_BEGIN

@interface MBButton : UIButton

/**
 图片文字对齐方式
 */
@property (nonatomic, assign) MBButtonAlignment buttonAlign;

/**
 图片文字间距
 */
@property (nonatomic, assign) CGFloat spaceBetweenTextAndImage;

/**
 重复点击的间隔
 */
@property (nonatomic, assign) NSTimeInterval acceptEventInterval;

@end

NS_ASSUME_NONNULL_END
