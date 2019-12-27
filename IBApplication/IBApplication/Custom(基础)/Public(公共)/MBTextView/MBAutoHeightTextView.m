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
@property (nonatomic, weak) id<MBAutoHeightTextViewDelegate> delegate;

@end

@implementation MBAutoHeightTextView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<MBAutoHeightTextViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    self.backgroundColor = [UIColor orangeColor];
    self.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    
    self.textView = [[MBTextView alloc] init];
    self.textView.isAutoHeight = YES;
    self.textView.minRowNumber = 1;
    self.textView.maxRowNumber = 3;
    
    self.textView.textViewDidChange = ^(NSString *text) {
        
    };
    
    __weak typeof(self) weakself = self;
    self.textView.textViewAutoHeight = ^(CGFloat textHeight) {
        [weakself layoutTextView:textHeight];
    };
    
    [self addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(self.edgeInsets);
    }];
    
}

- (void)layoutTextView:(CGFloat)height
{
    if (self.textView.superview) {
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(self.edgeInsets);
            make.height.mas_equalTo(height).priorityHigh();
        }];
    } else {
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        [self layoutIfNeeded];
    }];

}

@end
