//
//  MBTextView.m
//  IBApplication
//
//  Created by Bowen on 2019/12/25.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBTextView.h"

@interface MBTextView ()

@property (nonatomic, strong) UILabel *holderLabel;
@property (nonatomic, assign) CGFloat fontHeight;

@end

@implementation MBTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    [self addSubview:self.holderLabel];
    
    self.font = [UIFont systemFontOfSize:18];
    self.textContainerInset = UIEdgeInsetsZero;
    self.textAlignment = NSTextAlignmentLeft;
    self.backgroundColor = [UIColor clearColor];
    
    self.maxLength = NSUIntegerMax;
    self.minRowNumber = 1;
    self.maxRowNumber = 4;
    self.isAutoHeight = NO;
    self.canPerformAction = YES;
    self.inputState = MBTextViewInputDefault;
    self.placeholderTextColor = [UIColor lightGrayColor];
}

- (void)updateTextHeight {
    CGFloat height = 0;
    if (self.isAutoHeight) {
        CGFloat margin = self.textContainerInset.top + self.textContainerInset.bottom;
        CGFloat minHeight = self.minRowNumber * self.fontHeight + margin;
        CGFloat maxHeight = self.maxRowNumber * self.fontHeight + margin;
        if (self.text.length == 0) {
            height = minHeight;
        } else {
            height = [self sizeThatFits:self.frame.size].height;
            if (height != self.frame.size.height) {
                if (height > maxHeight) {
                    height = maxHeight;
                    self.scrollEnabled = YES;
                } else if (height < minHeight) {
                    height = minHeight;
                    self.scrollEnabled = NO;
                } else {
                    self.scrollEnabled = NO;
                }
            }
        }
        
        height = ceil(height);
        
        if (self.textViewAutoHeight) {
            self.textViewAutoHeight(height);
        }
    }
}

- (void)updateTextLength {
    NSString *progress = @"";
    if (self.inputState == MBTextViewInputDefault) {
        progress = @(self.text.length).stringValue;
    }
    if (self.inputState == MBTextViewInputDiminishing) {
        progress = @(self.maxLength - self.text.length).stringValue;
    }
    if (self.inputState == MBTextViewInputAscending) {
        progress = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)self.text.length, (unsigned long)self.maxLength];
    }
    if (self.textViewMaxLength) {
        self.textViewMaxLength(progress, self.text.length == self.maxLength);
    }
}

#pragma mark - notification

- (void)textDidChange {
    
    if (self.markedTextRange) {
        return;
    }
    
    self.holderLabel.hidden = self.hasText;
    
    if (self.text.length > self.maxLength) {
        self.text = [self.text substringToIndex:self.maxLength];
        [self.undoManager removeAllActions];
    }
    
    [self updateTextLength];
    
    [self updateTextHeight];
    
    if (self.textViewDidChange) {
        self.textViewDidChange(self.text);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat linePadding = self.textContainer.lineFragmentPadding;
    CGFloat rightMargin = linePadding + self.textContainerInset.right;
    
    CGFloat labelX = self.textContainerInset.left + linePadding;
    CGFloat labelY = self.textContainerInset.top;
    CGFloat labelW = self.bounds.size.width - rightMargin - labelX;
    CGFloat labelH = [self.holderLabel sizeThatFits:CGSizeMake(labelW, MAXFLOAT)].height;
    
    self.holderLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    if (self.contentSize.height <= self.bounds.size.height + 1) {
        // Fix wrong contentOfset
        self.contentOffset = CGPointZero;
    } else if (!self.tracking) {
        // Fix wrong contentOfset when past huge text
        CGPoint offset = self.contentOffset;
        if (offset.y  > self.contentSize.height - bounds.size.height) {
            offset.y = self.contentSize.height - bounds.size.height;
            if (!self.decelerating && !self.tracking && !self.dragging) {
                self.contentOffset = offset;
            }
        }
    }
}

- (BOOL)becomeFirstResponder {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:nil];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    return [super resignFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    BOOL result = [super canPerformAction:action withSender:sender];
    if (result) {
        if (![self respondsToSelector:action]) {
            result = NO;
        } else {
            result = self.canPerformAction;
        }
    }
    return result;
}

#pragma mark - setter, getter

- (void)setIsAutoHeight:(BOOL)isAutoHeight {
    _isAutoHeight = isAutoHeight;
    if (_isAutoHeight) {
        self.scrollEnabled = NO;
    }
}

- (void)setTextViewAutoHeight:(void (^)(CGFloat))textViewAutoHeight {
    _textViewAutoHeight = textViewAutoHeight;
    if (self.isAutoHeight) {
        [self updateTextHeight];
    }
}

- (void)setTextViewMaxLength:(void (^)(NSString *, BOOL))textViewMaxLength {
    _textViewMaxLength = textViewMaxLength;
    [self updateTextLength];
}

- (void)setTextViewDidChange:(void (^)(NSString *))textViewDidChange {
    _textViewDidChange = textViewDidChange;
    if (textViewDidChange) {
        textViewDidChange(self.text);
    }
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.holderLabel.text = placeholder;
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor {
    _placeholderTextColor = placeholderTextColor;
    self.holderLabel.textColor = placeholderTextColor;
}

- (void)setPlaceholderAttributedText:(NSAttributedString *)placeholderAttributedText {
    _placeholderAttributedText = placeholderAttributedText;
    self.holderLabel.attributedText = placeholderAttributedText;
}

- (void)setMaxLength:(NSUInteger)maxLength {
    if (maxLength <= 0) {
        maxLength = NSUIntegerMax;
    }
    if (self.text.length > maxLength) {
        self.text = [self.text substringToIndex:maxLength];
    }
    _maxLength = maxLength;
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.fontHeight = font.lineHeight;
    self.holderLabel.font = font;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textDidChange];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self textDidChange];
}

- (UILabel *)holderLabel {
    if (!_holderLabel) {
        _holderLabel = [[UILabel alloc] init];
        _holderLabel.text = @"请输入内容";
        _holderLabel.numberOfLines = 0;
    }
    return _holderLabel;
}

- (NSString *)formatText {
    // 去除首尾的空格和换行
    return [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
