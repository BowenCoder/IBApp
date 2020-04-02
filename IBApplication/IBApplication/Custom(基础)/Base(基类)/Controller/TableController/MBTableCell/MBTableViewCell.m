//
//  MBTableViewCell.m
//  IBApplication
//
//  Created by Bowen on 2018/7/30.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBTableViewCell.h"
#import "Masonry.h"

@interface MBTableViewCell ()

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation MBTableViewCell

+ (NSString *)identifier {
    return NSStringFromClass(self);
}

+ (instancetype)tableCellWithTableView:(UITableView *)tableView {
    NSString *tableCellID = [self identifier];
    MBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellID];
    if (!cell) {
        cell = [[MBTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorType = MBTableViewCellSeparatorNone;
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

    switch (self.separatorType) {
        case MBTableViewCellSeparatorNone: {
            self.topLine.hidden = YES;
            self.bottomLine.hidden = YES;
        }
            break;
        case MBTableViewCellSeparatorTop: {
            self.topLine.hidden = NO;
            self.bottomLine.hidden = YES;
            [self setTopLineLayout:YES bottomLayout:NO];
        }
            break;
        case MBTableViewCellSeparatorBottom: {
            self.topLine.hidden = YES;
            self.bottomLine.hidden = NO;
            [self setTopLineLayout:NO bottomLayout:YES];
        }
            break;
        case MBTableViewCellSeparatorBoth: {
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

- (void)setSeparatorType:(MBTableViewCellSeparatorType)separatorType {
    _separatorType = separatorType;
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
