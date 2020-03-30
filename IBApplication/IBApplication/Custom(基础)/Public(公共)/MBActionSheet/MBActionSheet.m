//
//  MBActionSheet.m
//  IBApplication
//
//  Created by Bowen on 2018/9/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBActionSheet.h"
#import "MBPopupView.h"
#import "IBString.h"
#import "UIMacros.h"

@interface MBActionSheet () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<NSArray *> *items;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) MBPopupView *popup;

@end

@implementation MBActionSheet

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id<MBActionSheetDelegate>)delegate cancelTitle:(NSString *)cancelTitle highlightedTitle:(NSString *)highlightedTitle otherTitles:(NSArray<NSString *> *)otherTitles {
    
    if (self = [super init]) {
        
        NSMutableArray *group = @[].mutableCopy;
        NSMutableArray *titleItems = @[].mutableCopy;
        //普通按钮
        for (NSString *otherTitle in otherTitles) {
            if (otherTitle && otherTitle.length > 0) {
                MBActionItem *item = [MBActionItem itemWithType:MBActionTypeNormal image:nil title:otherTitle tintColor:nil handler:nil];
                [titleItems addObject:item];
            }
        }
        // 高亮按钮, 高亮按钮放在最下面.
        if (highlightedTitle && highlightedTitle.length > 0) {
            MBActionItem *item = [MBActionItem itemWithType:MBActionTypeHighlighted image:nil title:highlightedTitle tintColor:nil handler:nil];
            [titleItems addObject:item];
        }
        [group addObject:titleItems];
        
        if (cancelTitle && cancelTitle.length > 0) {
            MBActionItem *cancel = [MBActionItem itemWithType:MBActionTypeNormal image:nil title:cancelTitle tintColor:nil handler:nil];
            [group addObject:@[cancel]];
        } else {
            MBActionItem *cancel = [MBActionItem itemWithType:MBActionTypeNormal image:nil title:@"取消" tintColor:nil handler:nil];
            [group addObject:@[cancel]];
        }

        self.items = [group copy];
        self.title = title;
        self.delegate = delegate;
        
        [self initView];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title cancelItem:(MBActionItem *)cancelItem items:(NSArray<MBActionItem *> *)items {

    if (self = [super init]) {
        
        NSMutableArray *group = [NSMutableArray array];
        
        if (items) {
            [group addObject:items];
        }

        if (cancelItem) {
            [group addObject:@[cancelItem]];
        } else {
            MBActionItem *cancel = [MBActionItem itemWithType:MBActionTypeNormal image:nil title:@"取消" tintColor:nil handler:nil];
            [group addObject:@[cancel]];
        }
        
        self.items = [group copy];
        self.title = title;

        [self initView];

    }
    return self;
}

- (void)show {
    [self.tableView reloadData];
    CGFloat contentHeight = self.tableView.contentSize.height + kSafeAreaBottomHeight;
    // 适配屏幕高度
    CGFloat contentMaxHeight = kScreenHeight * MBActionContentMaxScale + kSafeAreaBottomHeight;
    if (contentHeight > contentMaxHeight) {
        self.tableView.scrollEnabled = YES;
        contentHeight = contentMaxHeight;
    }
    self.frame = CGRectMake(0, 0, kScreenWidth, contentHeight);
    
    [self.popup presentContentView:self];
}

// 默认设置
- (void)initView {
    self.backgroundColor = [IBColor colorWithHexString:MBActionBGColor];
    self.translatesAutoresizingMaskIntoConstraints = NO; // 允许约束
    self.contentAlignment = MBContentAlignmentCenter; // 默认样式为居中
    [self addSubview:self.tableView];
}

// 适配标题偏移方向
- (void)updateTitleAttributeText {
    
    if (self.title.length == 0 || !self.titleLabel) return;
    
    // 富文本相关配置
    NSRange attributeRange  = NSMakeRange(0, self.title.length);
    UIFont  *titleFont      = [UIFont systemFontOfSize:14];
    UIColor *titleTextColor = [IBColor colorWithHexString:MBActionTitleColor];
    CGFloat lineSpacing     = MBActionTitleLineSpacing;
    CGFloat kernSpacing     = MBActionTitleKernSpacing;
    
    NSMutableAttributedString *titleAttributeString = [[NSMutableAttributedString alloc] initWithString:self.title];
    NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle alloc] init];
    // 行距
    titleStyle.lineSpacing = lineSpacing;
    // 内容偏移样式
    switch (self.contentAlignment) {
        case MBContentAlignmentLeft: {
            titleStyle.alignment = NSTextAlignmentLeft;
            break;
        }
        case MBContentAlignmentCenter: {
            titleStyle.alignment = NSTextAlignmentCenter;
            break;
        }
        case MBContentAlignmentRight: {
            titleStyle.alignment = NSTextAlignmentRight;
            break;
        }
    }
    [titleAttributeString addAttribute:NSParagraphStyleAttributeName value:titleStyle range:attributeRange];
    // 字距
    [titleAttributeString addAttribute:NSKernAttributeName value:@(kernSpacing) range:attributeRange];
    // 字体
    [titleAttributeString addAttribute:NSFontAttributeName value:titleFont range:attributeRange];
    // 颜色
    [titleAttributeString addAttribute:NSForegroundColorAttributeName value:titleTextColor range:attributeRange];
    self.titleLabel.attributedText = titleAttributeString;
}

// 计算title在设定宽度下的富文本高度
- (CGFloat)heightForHeaderView {
    CGFloat labelHeight = [self.titleLabel.attributedText boundingRectWithSize:CGSizeMake(kScreenWidth - MBActionDefaultMargin*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size.height;
    CGFloat headerHeight = ceil(labelHeight)+MBActionDefaultMargin*2;
    return headerHeight;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MBActionRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 1) ? MBActionSectionHeight : CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MBActionCell *cell = [tableView dequeueReusableCellWithIdentifier:[MBActionCell identifier]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MBActionCell *sheetCell = (MBActionCell *)cell;
    sheetCell.item = self.items[indexPath.section][indexPath.row];
    //第一组没有标题，隐藏第一个单元格的顶部线条
    if (indexPath.section == 0 && indexPath.row == 0 && (!self.title || self.title.length == 0)) {
        sheetCell.hideTopLine = YES;
    }
    //隐藏取消单元格的顶部线条
    if (indexPath.section == 1) {
        sheetCell.hideTopLine = YES;
    }
    sheetCell.contentAlignment = self.contentAlignment;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MBActionItem *item = self.items[indexPath.section][indexPath.row];
    if (item.handler) {
        item.handler(item, indexPath.row);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:selectedIndex:)]) {
        [self.delegate actionSheet:self selectedIndex:indexPath.row];
    }
    [self.popup dismiss];
}

#pragma mark - 合成存取

- (void)setContentAlignment:(MBContentAlignment)contentAlignment {
    if (_contentAlignment != contentAlignment) {
        _contentAlignment = contentAlignment;
        [self updateTitleAttributeText];
    }
}

- (UITableView *)tableView {
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = self.backgroundColor;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_tableView registerClass:[MBActionCell class] forCellReuseIdentifier:[MBActionCell identifier]];
        
        if (_title.length > 0) {
            _tableView.tableHeaderView = [self headerView];
        }
        
        if (@available(iOS 7.0, *)) {
            _tableView.estimatedRowHeight = 0.0;
            _tableView.estimatedSectionHeaderHeight = 0.0;
            _tableView.estimatedSectionFooterHeight = 0.0;
        }
    }
    return _tableView;
}

- (UIView *)headerView {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [IBColor colorWithHexString:MBActionRowNormalColor];
    // 标题
    [headerView addSubview:self.titleLabel];
    
    // 设置富文本标题内容
    [self updateTitleAttributeText];
    
    // 计算内容高度
    CGFloat headerHeight = [self heightForHeaderView];
    headerView.frame = CGRectMake(0, 0, kScreenWidth, headerHeight);
    
    // 约束
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_titleLabel]-margin-|"
                                                                       options:0.0
                                                                       metrics:@{@"margin" : @(MBActionDefaultMargin)}
                                                                         views:NSDictionaryOfVariableBindings(_titleLabel)]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[_titleLabel]"
                                                                       options:0.0
                                                                       metrics:@{@"margin" : @(MBActionDefaultMargin)}
                                                                         views:NSDictionaryOfVariableBindings(_titleLabel)]];
    return headerView;
}

- (UILabel *)titleLabel {
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.backgroundColor = [IBColor colorWithHexString:MBActionRowNormalColor];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _titleLabel;
}

- (MBPopupView *)popup {
    if(!_popup){
        _popup = [[MBPopupView alloc] init];
        _popup.layoutType = MBPopupLayoutTypeBottom;
    }
    return _popup;
}

@end
