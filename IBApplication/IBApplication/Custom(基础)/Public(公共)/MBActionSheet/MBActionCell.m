//
//  MBActionCell.m
//  IBApplication
//
//  Created by Bowen on 2018/9/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBActionCell.h"

@interface MBActionCell ()

@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIView *topLine; ///< 顶部线条

@end

@implementation MBActionCell

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
    
    self.backgroundColor = [IBColor colorWithHexString:MBActionRowNormalColor];
    self.contentView.backgroundColor = self.backgroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentAlignment = MBContentAlignmentCenter;
    
    [self.contentView addSubview:self.titleButton];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_titleButton)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_titleButton)]];
    
    [self.contentView addSubview:self.topLine];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topLine]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_topLine)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topLine(lineHeight)]" options:0 metrics:@{@"lineHeight":@(1)} views:NSDictionaryOfVariableBindings(_topLine)]];

}

// 更新button图片与标题的edge
- (void)updateButtonContentEdge {
    if (!self.item.image) return;
    if (self.contentAlignment == MBContentAlignmentRight) {
        CGFloat titleWidth = [[self.titleButton titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName:self.titleButton.titleLabel.font}].width;
        _titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth, 1, -titleWidth);
        _titleButton.titleEdgeInsets = UIEdgeInsetsMake(1, -self.item.image.size.width-MBActionItemContentSpacing,
                                                        0, self.item.image.size.width+MBActionItemContentSpacing);
    } else {
        _titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, -MBActionItemContentSpacing/2, 1, MBActionItemContentSpacing/2);
        _titleButton.titleEdgeInsets = UIEdgeInsetsMake(1, MBActionItemContentSpacing/2, 0, -MBActionItemContentSpacing/2);
    }
}


#pragma mark - 合成存取

- (void)setHideTopLine:(BOOL)hideTopLine {
    self.topLine.hidden = hideTopLine;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.contentView.backgroundColor = [IBColor colorWithHexString:MBActionRowHighlightedColor];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.contentView.backgroundColor = self.backgroundColor;
        }];
    }
}

- (void)setItem:(MBActionItem *)item {
    _item = item;
    
    // 前景色设置
    UIColor *tintColor;
    if (_item.tintColor) {
        tintColor = _item.tintColor;
    } else {
        if (_item.type == MBActionTypeNormal) {
            tintColor = [IBColor colorWithHexString:MBActionItemNormalColor];
        } else {
            tintColor = [IBColor colorWithHexString:MBActionItemHighlightedColor];
        }
    }
    // 调整图片与标题的间距
    CGFloat imgLeft = _item.image ? -MBActionItemContentSpacing / 2 : 0;
    CGFloat imgBottom = _item.image ? 1 : 0;
    CGFloat imgRight = _item.image ? MBActionItemContentSpacing / 2 : 0;
    self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, imgLeft, imgBottom, imgRight);
    
    CGFloat titleTop = _item.image ? 1 : 0;
    CGFloat titleLeft = _item.image ? MBActionItemContentSpacing / 2 : 0;
    CGFloat titleRight = _item.image ? MBActionItemContentSpacing / 2 : 0;
    self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(titleTop, titleLeft, 0, titleRight);
    
    // 设置图片与标题
    [self.titleButton setTintColor:tintColor];
    [self.titleButton setTitle:_item.title forState:UIControlStateNormal];
    [self.titleButton setImage:_item.image forState:UIControlStateNormal];
}

- (void)setContentAlignment:(MBContentAlignment)contentAlignment {
    if (_contentAlignment == contentAlignment) return;

    _contentAlignment = contentAlignment;
    // 更新button的图片和标题Edge
    [self updateButtonContentEdge];
    // 设置内容偏移
    switch (_contentAlignment) {
        case MBContentAlignmentLeft: { // 局左
            _titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            _titleButton.contentEdgeInsets = UIEdgeInsetsMake(0, MBActionDefaultMargin, 0, -MBActionDefaultMargin);
            break;
        }
        case MBContentAlignmentCenter: { // 居中
            _titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            _titleButton.contentEdgeInsets = UIEdgeInsetsZero;
            break;
        }
        case MBContentAlignmentRight: { // 居右
            _titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            _titleButton.contentEdgeInsets = UIEdgeInsetsMake(0, -MBActionDefaultMargin, 0, MBActionDefaultMargin);
            break;
        }
    }
}

- (UIButton *)titleButton {
    if(!_titleButton){
        _titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _titleButton.tintColor = [IBColor colorWithHexString:MBActionItemNormalColor];
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:MBActionItemTitleFontSize];
        _titleButton.userInteractionEnabled = NO;
        _titleButton.translatesAutoresizingMaskIntoConstraints = NO;

    }
    return _titleButton;
}

- (UIView *)topLine {
    if(!_topLine){
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = [IBColor colorWithHexString:MBActionRowTopLineColor];
        _topLine.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _topLine;
}



@end
