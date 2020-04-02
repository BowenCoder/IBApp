//
//  MBTableViewController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/6.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBTableViewController.h"
#import "UIView+Ext.h"
#import "UIMacros.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "MBRefreshHeader.h"
#import "MBRefreshFooter.h"

@interface MBTableViewController ()


@end

@implementation MBTableViewController

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    
    if (@available(iOS 11.0, *)) {
    } else {
        [_tableView removeObserver:self forKeyPath:@"contentInset"];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self layoutTableView];
    [self layoutEmptyView];
}

- (void)setupUI
{
    [super setupUI];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self.view);
    }];
}

- (void)loadLastData
{

}

- (void)loadMoreData
{
    
}

- (void)layoutTableView
{
    BOOL shouldChangeTableViewFrame = !CGRectEqualToRect(self.view.bounds, self.tableView.frame);
    if (shouldChangeTableViewFrame) {
        self.tableView.frameApplyTransform = self.view.bounds;
    }
}

#pragma mark - MJRefresh

- (void)addRefreshHeader
{
    MBRefreshHeader *header = [MBRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadLastData)];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.automaticallyChangeAlpha = YES;
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
}

- (void)removeRefreshHeader
{
    if (self.tableView.mj_header) {
        [self.tableView.mj_header removeFromSuperview];
        self.tableView.mj_header = nil;
    }
}

- (void)beginHeaderRefresh
{
    [self.tableView.mj_header beginRefreshing];
}

- (void)endRefreshHeader
{
    [self.tableView.mj_header endRefreshing];
}

- (void)addRefreshFooter
{
    MBRefreshFooter *footer = [MBRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.tableView.mj_footer = footer;
}

- (void)removeRefreshFooter
{
    if (self.tableView.mj_footer) {
        [self.tableView.mj_footer removeFromSuperview];
        self.tableView.mj_footer = nil;
    }
}

- (void)endRefreshFooter
{
    [self.tableView.mj_footer endRefreshing];
}

- (void)endRefreshFooterNoMoreData
{
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
}

- (void)resetRefreshFooterNoMoreData
{
    [self.tableView.mj_footer resetNoMoreData];
}

- (void)setFooterRefreshHidden:(BOOL)isHidden
{
    self.tableView.mj_footer.hidden = isHidden;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        UIView *view = [tableView.delegate tableView:tableView viewForHeaderInSection:section];
        if (view) {
            CGFloat height = [view sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds) - UIEdgeInsetsGetHorizontalValue(tableView.safeAreaEdgeInsets), CGFLOAT_MAX)].height;
            return height;
        }
    }
    // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
    return tableView.style == UITableViewStylePlain ? 0 : CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([tableView.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        UIView *view = [tableView.delegate tableView:tableView viewForFooterInSection:section];
        if (view) {
            CGFloat height = [view sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds) - UIEdgeInsetsGetHorizontalValue(tableView.safeAreaEdgeInsets), CGFLOAT_MAX)].height;
            return height;
        }
    }
    // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
    return tableView.style == UITableViewStylePlain ? 0 : CGFLOAT_MIN;
}

/**
 *  监听 contentInset 的变化以及时更新 emptyView 的布局，详见 layoutEmptyView 方法的注释
 *  该 delegate 方法仅在 iOS 11 及之后存在，之前的 iOS 版本使用 KVO 的方式实现监听，详见 initTableView 方法里的相关代码
 */
- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView
{
    if (scrollView != self.tableView) {
        return;
    }
    [self handleTableViewContentInsetChangeEvent];
}

#pragma mark - 通知

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentInset"]) {
        [self handleTableViewContentInsetChangeEvent];
    }
}

#pragma mark - 空视图

- (void)handleTableViewContentInsetChangeEvent
{
    if (self.isEmptyViewShowing) {
        [self layoutEmptyView];
    }
}

- (void)showEmptyView
{
    [self.tableView addSubview:self.emptyView];
    [self layoutEmptyView];
}

// 注意，emptyView 的布局依赖于 tableView.contentInset，因此我们必须监听 tableView.contentInset 的变化以及时更新 emptyView 的布局
- (BOOL)layoutEmptyView
{
    if (!_emptyView || !_emptyView.superview) {
        return NO;
    }
    
    UIEdgeInsets insets = self.tableView.contentInset;
    if (@available(iOS 11, *)) {
        if (self.tableView.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
            insets = self.tableView.adjustedContentInset;
        }
    }
    
    // 当存在 tableHeaderView 时，emptyView 的高度为 tableView 的高度减去 headerView 的高度
    if (self.tableView.tableHeaderView) {
        self.emptyView.frame = CGRectMake(0, CGRectGetMaxY(self.tableView.tableHeaderView.frame), CGRectGetWidth(self.tableView.bounds) - UIEdgeInsetsGetHorizontalValue(insets), CGRectGetHeight(self.tableView.bounds) - UIEdgeInsetsGetVerticalValue(insets) - CGRectGetMaxY(self.tableView.tableHeaderView.frame));
    } else {
        self.emptyView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds) - UIEdgeInsetsGetHorizontalValue(insets), CGRectGetHeight(self.tableView.bounds) - UIEdgeInsetsGetVerticalValue(insets));
    }
    return YES;
}

#pragma mark - 合成存取

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.tableFooterView = [[UIView alloc] init];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            /**
             *  监听 contentInset 的变化以及时更新 emptyView 的布局，详见 layoutEmptyView 方法的注释
             *  iOS 11 及之后使用 UIScrollViewDelegate 的 scrollViewDidChangeAdjustedContentInset: 来监听
             */
            [_tableView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionOld context:nil];
        }
    }
    return _tableView;
}

@end
