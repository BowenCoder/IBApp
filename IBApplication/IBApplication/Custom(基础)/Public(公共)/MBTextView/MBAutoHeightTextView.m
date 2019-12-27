//
//  MBAutoHeightTextView.m
//  IBApplication
//
//  Created by Bowen on 2019/12/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBAutoHeightTextView.h"
#import "MBTextView.h"
#import "Masonry.h"

@interface MBAutoHeightTextView ()

@property (nonatomic, strong) MBTextView *textView;
@property (nonatomic, assign) UIEdgeInsets textEdgeInsets;
@property (nonatomic, weak) id<MBAutoHeightTextViewDataSource> dataSource;

@end

@implementation MBAutoHeightTextView

- (instancetype)initWithDataSource:(id<MBAutoHeightTextViewDataSource>)dataSource;
{
    self = [super init];
    if (self) {
        self.dataSource = dataSource;
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    __weak typeof(self) weakself = self;

    self.backgroundColor = [UIColor whiteColor];
    self.textEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    
    self.textView = [[MBTextView alloc] init];
    self.textView.isAutoHeight = YES;
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(textFont)]) {
        self.textView.font = [self.dataSource textFont];
    }
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(textMinNumberOfLines)]) {
        self.textView.minRowNumber = [self.dataSource textMinNumberOfLines];
    }
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(textMaxNumberOfLines)]) {
        self.textView.maxRowNumber = [self.dataSource textMaxNumberOfLines];
    }
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(textEdgeInsets)]) {
        self.textEdgeInsets = [self.dataSource textEdgeInsets];
    }
    
    self.textView.textViewDidChange = ^(NSString *text) {
        if (weakself.textViewDidChange) {
            weakself.textViewDidChange(text);
        }
    };
    
    self.textView.textViewAutoHeight = ^(CGFloat textHeight) {
        [weakself.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(textHeight);
        }];
        [UIView animateWithDuration:0.1 animations:^{
            [weakself.superview layoutIfNeeded];
        }];
    };
    
    [self addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(self.textEdgeInsets);
    }];
    
}

#pragma mark - getter, setter

- (void)setText:(NSString *)text {
    self.textView.text = text;
}

- (void)setTextColor:(UIColor *)textColor {
    self.textView.textColor = textColor;
}

- (void)setCursorColor:(UIColor *)cursorColor {
    self.textView.tintColor = cursorColor;
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.textView.placeholder = placeholder;
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor {
    self.textView.placeholderTextColor = placeholderTextColor;
}

- (void)setPlaceholderAttributedText:(NSAttributedString *)placeholderAttributedText {
    self.textView.placeholderAttributedText = placeholderAttributedText;
}




@end
