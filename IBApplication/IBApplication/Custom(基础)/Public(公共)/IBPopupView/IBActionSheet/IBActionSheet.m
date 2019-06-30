//
//  IBActionSheet.m
//  IBApplication
//
//  Created by Bowen on 2018/9/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBActionSheet.h"
#import "IBPopupManager.h"
#import "IBString.h"
#import "UIMacros.h"

@interface IBActionSheet () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<NSArray *> *items;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) IBPopupManager *popupManager;

@end

@implementation IBActionSheet

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id<IBActionSheetDelegate>)delegate cancelTitle:(NSString *)cancelTitle highlightedTitle:(NSString *)highlightedTitle otherTitles:(NSArray<NSString *> *)otherTitles {
    
    if (self = [super init]) {
        
        NSMutableArray *group = @[].mutableCopy;
        NSMutableArray *titleItems = @[].mutableCopy;
        //普通按钮
        for (NSString *otherTitle in otherTitles) {
            if (otherTitle && otherTitle.length > 0) {
                IBActionItem *item = [IBActionItem itemWithType:IBActionTypeNormal image:nil title:otherTitle tintColor:nil handler:nil];
                [titleItems addObject:item];
            }
        }
        // 高亮按钮, 高亮按钮放在最下面.
        if (highlightedTitle && highlightedTitle.length > 0) {
            IBActionItem *item = [IBActionItem itemWithType:IBActionTypeHighlighted image:nil title:highlightedTitle tintColor:nil handler:nil];
            [titleItems addObject:item];
        }
        [group addObject:titleItems];
        
        if (cancelTitle && cancelTitle.length > 0) {
            IBActionItem *cancel = [IBActionItem itemWithType:IBActionTypeNormal image:nil title:cancelTitle tintColor:nil handler:nil];
            [group addObject:@[cancel]];
        } else {
            IBActionItem *cancel = [IBActionItem itemWithType:IBActionTypeNormal image:nil title:@"取消" tintColor:nil handler:nil];
            [group addObject:@[cancel]];
        }

        self.items = [group copy];
        self.title = title;
        self.delegate = delegate;
        
        [self initView];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title cancelItem:(IBActionItem *)cancelItem items:(NSArray<IBActionItem *> *)items {

    if (self = [super init]) {
        
        NSMutableArray *group = [NSMutableArray array];
        
        if (items) {
            [group addObject:items];
        }

        if (cancelItem) {
            [group addObject:@[cancelItem]];
        } else {
            IBActionItem *cancel = [IBActionItem itemWithType:IBActionTypeNormal image:nil title:@"取消" tintColor:nil handler:nil];
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
    CGFloat contentMaxHeight = kScreenHeight * IBActionContentMaxScale + kSafeAreaBottomHeight;
    if (contentHeight > contentMaxHeight) {
        self.tableView.scrollEnabled = YES;
        contentHeight = contentMaxHeight;
    }
    self.frame = CGRectMake(0, 0, kScreenWidth, contentHeight);
    
    [self.popupManager presentContentView:self];
}

// 默认设置
- (void)initView {
    self.backgroundColor = [IBColor colorWithHexString:IBActionBGColor];
    self.translatesAutoresizingMaskIntoConstraints = NO; // 允许约束
    self.contentAlignment = IBContentAlignmentCenter; // 默认样式为居中
    [self addSubview:self.tableView];
}

// 适配标题偏移方向
- (void)updateTitleAttributeText {
    
    if (self.title.length == 0 || !self.titleLabel) return;
    
    // 富文本相关配置
    NSRange attributeRange  = NSMakeRange(0, self.title.length);
    UIFont  *titleFont      = [UIFont systemFontOfSize:14];
    UIColor *titleTextColor = [IBColor colorWithHexString:IBActionTitleColor];
    CGFloat lineSpacing     = IBActionTitleLineSpacing;
    CGFloat kernSpacing     = IBActionTitleKernSpacing;
    
    NSMutableAttributedString *titleAttributeString = [[NSMutableAttributedString alloc] initWithString:self.title];
    NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle alloc] init];
    // 行距
    titleStyle.lineSpacing = lineSpacing;
    // 内容偏移样式
    switch (self.contentAlignment) {
        case IBContentAlignmentLeft: {
            titleStyle.alignment = NSTextAlignmentLeft;
            break;
        }
        case IBContentAlignmentCenter: {
            titleStyle.alignment = NSTextAlignmentCenter;
            break;
        }
        case IBContentAlignmentRight: {
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
    CGFloat labelHeight = [self.titleLabel.attributedText boundingRectWithSize:CGSizeMake(kScreenWidth - IBActionDefaultMargin*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size.height;
    CGFloat headerHeight = ceil(labelHeight)+IBActionDefaultMargin*2;
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
    return IBActionRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 1) ? IBActionSectionHeight : CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IBActionCell *cell = [tableView dequeueReusableCellWithIdentifier:[IBActionCell identifier]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IBActionCell *sheetCell = (IBActionCell *)cell;
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
    
    IBActionItem *item = self.items[indexPath.section][indexPath.row];
    if (item.handler) {
        item.handler(item, indexPath.row);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:selectedIndex:)]) {
        [self.delegate actionSheet:self selectedIndex:indexPath.row];
    }
    [self.popupManager dismiss];
}

#pragma mark - 合成存取

- (void)setContentAlignment:(IBContentAlignment)contentAlignment {
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
        [_tableView registerClass:[IBActionCell class] forCellReuseIdentifier:[IBActionCell identifier]];
        
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
    headerView.backgroundColor = [IBColor colorWithHexString:IBActionRowNormalColor];
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
                                                                       metrics:@{@"margin" : @(IBActionDefaultMargin)}
                                                                         views:NSDictionaryOfVariableBindings(_titleLabel)]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[_titleLabel]"
                                                                       options:0.0
                                                                       metrics:@{@"margin" : @(IBActionDefaultMargin)}
                                                                         views:NSDictionaryOfVariableBindings(_titleLabel)]];
    return headerView;
}

- (UILabel *)titleLabel {
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.backgroundColor = [IBColor colorWithHexString:IBActionRowNormalColor];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _titleLabel;
}

- (IBPopupManager *)popupManager {
    if(!_popupManager){
        _popupManager = [[IBPopupManager alloc] init];
        _popupManager.layoutType = IBPopupLayoutTypeBottom;
    }
    return _popupManager;
}

@end
