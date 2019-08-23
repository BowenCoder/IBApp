//
//  MBBlurImageView.h
//  IBApplication
//
//  Created by Bowen on 2019/8/23.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBImageView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 高斯图片视图
 */
@interface MBBlurImageView : MBImageView

@property (nonatomic, assign) UIBlurEffectStyle effectStyle;

@end

NS_ASSUME_NONNULL_END
