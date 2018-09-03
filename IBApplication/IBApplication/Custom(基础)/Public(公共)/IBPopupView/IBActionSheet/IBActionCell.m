//
//  IBActionCell.m
//  IBApplication
//
//  Created by Bowen on 2018/9/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBActionCell.h"

@interface IBActionCell ()

@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIView *topLine; ///< 顶部线条

@end

@implementation IBActionCell

+ (NSString *)identifier {
    return NSStringFromClass(self);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupCell];
    }
    return self;
}

- (void)setupCell {
    
    self.backgroundColor = [IBColor colorWithHexString:IBActionRowNormalColor];
    self.contentView.backgroundColor = self.backgroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentAlignment = IBContentAlignmentCenter;
    
    [self.contentView addSubview:self.titleButton];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self.titleButton)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self.titleButton)]];
    
    [self.contentView addSubview:self.topLine];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topLine]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self.topLine)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLine(lineHeight)]" options:0 metrics:@{@"lineHeight":@(1)} views:NSDictionaryOfVariableBindings(self.topLine)]];

}

// 更新button图片与标题的edge
- (void)updateButtonContentEdge {
    if (!self.item.image) return;
    if (self.contentAlignment == IBContentAlignmentRight) {
        CGFloat titleWidth = [[self.titleButton titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName:self.titleButton.titleLabel.font}].width;
        _titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth, 1, -titleWidth);
        _titleButton.titleEdgeInsets = UIEdgeInsetsMake(1, -self.item.image.size.width-IBActionItemContentSpacing,
                                                        0, self.item.image.size.width+IBActionItemContentSpacing);
    } else {
        _titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, -IBActionItemContentSpacing/2, 1, IBActionItemContentSpacing/2);
        _titleButton.titleEdgeInsets = UIEdgeInsetsMake(1, IBActionItemContentSpacing/2, 0, -IBActionItemContentSpacing/2);
    }
}


#pragma mark - 合成存取

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.contentView.backgroundColor = [IBColor colorWithHexString:IBActionRowHighlightedColor];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.contentView.backgroundColor = self.backgroundColor;
        }];
    }
}

- (void)setItem:(IBActionItem *)item {
    _item = item;
    
    // 前景色设置, 如果有自定义前景色则使用自定义的前景色, 否则使用预配置的颜色值.
    UIColor *tintColor;
    if (item.tintColor) {
        tintColor = item.tintColor;
    } else {
        if (_item.type == IBActionTypeNormal) {
            tintColor = [IBColor colorWithHexString:IBActionItemNormalColor];
        } else {
            tintColor = [IBColor colorWithHexString:IBActionItemHighlightedColor];
        }
    }
    self.titleButton.tintColor = tintColor;
    
    // 调整图片与标题的间距
    CGFloat imgLeft = _item.image ? -IBActionItemContentSpacing / 2 : 0;
    CGFloat imgBottom = _item.image ? 1 : 0;
    CGFloat imgRight = _item.image ? IBActionItemContentSpacing / 2 : 0;
    self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, imgLeft, imgBottom, imgRight);
    
    CGFloat titleTop = _item.image ? 1 : 0;
    CGFloat titleLeft = _item.image ? IBActionItemContentSpacing / 2 : 0;
    CGFloat titleRight = _item.image ? IBActionItemContentSpacing / 2 : 0;
    self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(titleTop, titleLeft, 0, titleRight);
    
    // 设置图片与标题
    [self.titleButton setTitle:_item.title forState:UIControlStateNormal];
    [self.titleButton setImage:_item.image forState:UIControlStateNormal];
}

- (void)setContentAlignment:(IBContentAlignment)contentAlignment {
    if (_contentAlignment == contentAlignment) return;

    _contentAlignment = contentAlignment;
    // 更新button的图片和标题Edge
    [self updateButtonContentEdge];
    // 设置内容偏移
    switch (_contentAlignment) {
        case IBContentAlignmentLeft: { // 局左
            _titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            _titleButton.contentEdgeInsets = UIEdgeInsetsMake(0, IBActionDefaultMargin, 0, -IBActionDefaultMargin);
            break;
        }
        case IBContentAlignmentCenter: { // 居中
            _titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            _titleButton.contentEdgeInsets = UIEdgeInsetsZero;
            break;
        }
        case IBContentAlignmentRight: { // 居右
            _titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            _titleButton.contentEdgeInsets = UIEdgeInsetsMake(0, -IBActionDefaultMargin, 0, IBActionDefaultMargin);
            break;
        }
    }
}

- (UIButton *)titleButton {
    if(!_titleButton){
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleButton.tintColor = [IBColor colorWithHexString:IBActionItemNormalColor];
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:IBActionItemTitleFontSize];
        _titleButton.userInteractionEnabled = NO;
        _titleButton.translatesAutoresizingMaskIntoConstraints = NO;

    }
    return _titleButton;
}

- (UIView *)topLine {
    if(!_topLine){
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = [IBColor colorWithHexString:IBActionRowTopLineColor];
        _topLine.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _topLine;
}



@end
