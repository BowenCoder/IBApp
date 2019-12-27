//
//  MBAutoHeightTextView.h
//  IBApplication
//
//  Created by Bowen on 2019/12/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MBAutoHeightTextViewDelegate <NSObject>

- (UIFont *)textViewFont;
- (UIColor *)textViewTextColor;
- (UIColor *)textViewPlaceholderTextColor;
- (NSUInteger)textViewMinNumberOfLines;
- (NSUInteger)textViewMaxNumberOfLines;

@end

@interface MBAutoHeightTextView : UIView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<MBAutoHeightTextViewDelegate>)delegate;

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end

NS_ASSUME_NONNULL_END
