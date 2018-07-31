//
//  IBTableController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/6.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBTableController.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "IBRefreshHeader.h"
#import "IBRefreshFooter.h"

@interface IBTableController ()


@end

@implementation IBTableController

- (void)initUI {
    [super initUI];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self.view);
    }];
}

- (void)loadLastData {

}

- (void)loadMoreData {
    
}

#pragma mark - MJRefresh

- (void)addRefreshHeader {
    IBRefreshHeader *header = [IBRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadLastData)];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.automaticallyChangeAlpha = YES;
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
}

- (void)removeRefreshHeader {
    if (self.tableView.mj_header) {
        [self.tableView.mj_header removeFromSuperview];
        self.tableView.mj_header = nil;
    }
}

- (void)beginHeaderRefresh {
    [self.tableView.mj_header beginRefreshing];
}

- (void)endRefreshHeader {
    [self.tableView.mj_header endRefreshing];
}

- (void)addRefreshFooter {
    IBRefreshFooter *footer = [IBRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    self.tableView.mj_footer = footer;
}

- (void)removeRefreshFooter {
    if (self.tableView.mj_footer) {
        [self.tableView.mj_footer removeFromSuperview];
        self.tableView.mj_footer = nil;
    }
}

- (void)endRefreshFooter {
    [self.tableView.mj_footer endRefreshing];
}

- (void)endRefreshFooterNoMoreData {
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
}

- (void)resetRefreshFooterNoMoreData {
    [self.tableView.mj_footer resetNoMoreData];
}

- (void)setFooterRefreshHidden:(BOOL)isHidden {
    self.tableView.mj_footer.hidden = isHidden;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
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
    }
    return _tableView;
}

@end
