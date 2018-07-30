//
//  IBTableCell.m
//  IBApplication
//
//  Created by Bowen on 2018/7/30.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBTableCell.h"
#import "Masonry.h"

@interface IBTableCell ()

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation IBTableCell

+ (NSString *)identifier {
    return NSStringFromClass(self);
}

+ (instancetype)tableCellWithTableView:(UITableView *)tableView {
    NSString *tableCellID = [IBTableCell identifier];
    IBTableCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellID];
    if (!cell) {
        cell = [[IBTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorStyle = IBTableCellSeparatorNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupCell];
    }
    return self;
}


- (void)setupCell {
    
}

- (void)updateConstraints {
    
    switch (self.separatorStyle) {
        case IBTableCellSeparatorNone: {
            self.topLine.hidden = YES;
            self.bottomLine.hidden = YES;
        }
            break;
        case IBTableCellSeparatorTop: {
            self.topLine.hidden = NO;
            self.bottomLine.hidden = YES;
            [self setTopLineLayout:YES bottomLayout:NO];
        }
            break;
        case IBTableCellSeparatorBottom: {
            self.topLine.hidden = YES;
            self.bottomLine.hidden = NO;
            [self setTopLineLayout:NO bottomLayout:YES];
        }
            break;
        case IBTableCellSeparatorBoth: {
            self.topLine.hidden = NO;
            self.bottomLine.hidden = NO;
            [self setTopLineLayout:YES bottomLayout:YES];
        }
            break;
        default:
            break;
    }
    [super updateConstraints];
}

- (void)setTopLineLayout:(BOOL)topLayout bottomLayout:(BOOL)bottomLayout {
    
    if (topLayout) {
        [self.topLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.height.equalTo(@0.5);
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
    }
    
    if (bottomLayout) {
        [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.height.equalTo(@0.5);
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
    }
}

#pragma mark - 合成存取

- (void)setSeperatorColor:(UIColor *)seperatorColor {
    _seperatorColor = seperatorColor;
    self.topLine.backgroundColor = seperatorColor;
    self.bottomLine.backgroundColor = seperatorColor;
}

- (void)setSeparatorStyle:(IBTableCellSeparatorStyle)separatorStyle {
    _separatorStyle = separatorStyle;
    [self setNeedsUpdateConstraints];
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_topLine];
    }
    return _topLine;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_bottomLine];
    }
    return _bottomLine;
}

@end
