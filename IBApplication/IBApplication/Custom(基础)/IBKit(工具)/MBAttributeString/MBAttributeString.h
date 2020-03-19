//
//  MBAttributeString.h
//  IBApplication
//
//  Created by Bowen on 2020/3/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBAttributeString : NSObject

/**
 * @brief 创建一个包含图片的 attributedString
 * @param image 要用的图片
 */
+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image;

/**
 * @brief 创建一个包含图片的 attributedString
 * @param image 要用的图片
 * @param offset 图片相对基线的垂直偏移（当 offset > 0 时，图片会向上偏移）
 * @param leftMargin 图片距离左侧内容的间距
 * @param rightMargin 图片距离右侧内容的间距
 * @note leftMargin 和 rightMargin 必须大于或等于 0
 */
+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)offset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;

@end

NS_ASSUME_NONNULL_END
