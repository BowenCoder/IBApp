//
//  MBTextView.h
//  IBApplication
//
//  Created by Bowen on 2019/12/25.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 文字输入进度格式枚举 **/
typedef NS_ENUM(NSInteger, MBTextViewInputState) {
    MBTextViewInputDefault = 0,    // 默认模式
    MBTextViewInputAscending = 1,  // 递增模式
    MBTextViewInputDiminishing = 2 // 递减模式
};

@interface MBTextView : UITextView

/** 占位字符 */
@property (nonatomic, copy) NSString *placeholder;
/** 占位字符颜色 */
@property (nonatomic, strong) UIColor *placeholderTextColor;
/** 占位富文本 */
@property (nonatomic, copy) NSAttributedString *placeholderAttributedText;
/** 自适应高度，默认为NO */
@property (nonatomic, assign) BOOL isAutoHeight;
/** 设置最小行数 */
@property (nonatomic, assign) CGFloat minRowNumber;
/** 设置最大行数 */
@property (nonatomic, assign) CGFloat maxRowNumber;
/** 最大限制文本长度，默认不限制 */
@property (nonatomic, assign) NSUInteger maxLength;
/** 弹UIMenuController， 默认为YES. */
@property (nonatomic, assign) BOOL canPerformAction;
/** 文字输入进度格式 */
@property (nonatomic, assign) MBTextViewInputState inputState;

/** 文本回调 */
@property (nonatomic, copy) void(^textViewDidChange)(NSString *text);
/** 高度回调 */
@property (nonatomic, copy) void(^textViewAutoHeight)(CGFloat textHeight);
/** 进度回调 */
@property (nonatomic, copy) void(^textViewMaxLength)(NSString *progress, BOOL isMax);

/** 清除首位的空格和换行 */
- (NSString *)formatText;

@end

NS_ASSUME_NONNULL_END
