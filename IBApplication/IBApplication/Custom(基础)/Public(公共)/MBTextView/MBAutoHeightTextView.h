//
//  MBAutoHeightTextView.h
//  IBApplication
//
//  Created by Bowen on 2019/12/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MBAutoHeightTextViewDataSource <NSObject>

@optional
- (UIFont *)textFont;
- (UIEdgeInsets)textEdgeInsets;
- (NSUInteger)textMinNumberOfLines;
- (NSUInteger)textMaxNumberOfLines;

@end

@interface MBAutoHeightTextView : UIView

- (instancetype)initWithDataSource:(nullable id<MBAutoHeightTextViewDataSource>)dataSource;

/** 文本 */
@property (nonatomic, copy) NSString *text;
/** 文本颜色 */
@property (nonatomic, strong) UIColor *textColor;
/** 光标颜色 */
@property (nonatomic, strong) UIColor *cursorColor;
/** 占位字符 */
@property (nonatomic, copy) NSString *placeholder;
/** 占位字符颜色 */
@property (nonatomic, strong) UIColor *placeholderTextColor;

/** 文本回调 */
@property (nonatomic, copy) void(^textViewDidChange)(NSString *text);

@end

NS_ASSUME_NONNULL_END
