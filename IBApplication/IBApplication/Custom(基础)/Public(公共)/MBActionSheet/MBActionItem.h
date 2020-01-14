//
//  MBActionItem.h
//  IBApplication
//
//  Created by Bowen on 2018/9/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBActionItem;

// 选择选项block回调
typedef void(^MBActionHandler)(MBActionItem *item ,NSInteger selectedIndex);

// 选项类型枚举
typedef NS_ENUM(NSInteger, MBActionType) {
    MBActionTypeNormal = 0,    // 正常状态
    MBActionTypeHighlighted,   // 高亮状态
};

// 内容偏移枚举
typedef NS_ENUM(NSInteger, MBContentAlignment) {
    MBContentAlignmentLeft = 0,     // 内容紧靠左边
    MBContentAlignmentCenter,       // 内容居中
    MBContentAlignmentRight,        // 内容紧靠右边
};

@interface MBActionItem : NSObject

@property (nonatomic, assign) MBActionType type; ///< 选项类型, 有 默认 和 高亮 两种类型.
@property (nonatomic, strong) UIImage  *image; ///< 选项图标, 建议image的size为 @2x: 46x46, @3x: 69x69.
@property (nonatomic, copy)   NSString *title; ///< 选项标题
@property (nonatomic, strong) UIColor  *tintColor; ///< 图标和文本颜色
@property (nonatomic, copy)   MBActionHandler handler; ///< 选择回调

+ (instancetype)itemWithType:(MBActionType)type image:(UIImage *)image title:(NSString *)title tintColor:(UIColor *)tintColor handler:(MBActionHandler)handler;

@end

// float
UIKIT_EXTERN CGFloat const MBActionDefaultMargin; ///< 默认边距 (标题四边边距, 选项靠左或靠右时距离边缘的距离)
UIKIT_EXTERN CGFloat const MBActionContentMaxScale; ///< 弹窗内容高度与屏幕高度的默认比例
UIKIT_EXTERN CGFloat const MBActionRowHeight; ///< 行高
UIKIT_EXTERN CGFloat const MBActionTitleLineSpacing; ///< 标题行距
UIKIT_EXTERN CGFloat const MBActionTitleKernSpacing; ///< 标题字距
UIKIT_EXTERN CGFloat const MBActionItemTitleFontSize; ///< 选项文字字体大小
UIKIT_EXTERN CGFloat const MBActionItemContentSpacing; ///< 选项图片和文字的间距
UIKIT_EXTERN CGFloat const MBActionSectionHeight; ///< 分区间距
// color
UIKIT_EXTERN NSString * const MBActionTitleColor; ///< 标题颜色
UIKIT_EXTERN NSString * const MBActionBGColor; ///< 背景颜色
UIKIT_EXTERN NSString * const MBActionRowNormalColor; ///< 单元格背景颜色
UIKIT_EXTERN NSString * const MBActionRowHighlightedColor; ///< 选中高亮颜色
UIKIT_EXTERN NSString * const MBActionRowTopLineColor; ///< 单元格顶部线条颜色
UIKIT_EXTERN NSString * const MBActionItemNormalColor; ///< 选项默认颜色
UIKIT_EXTERN NSString * const MBActionItemHighlightedColor; ///< 选项高亮颜色

