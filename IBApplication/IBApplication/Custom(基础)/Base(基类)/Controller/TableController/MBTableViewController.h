//
//  MBTableViewController.h
//  IBApplication
//
//  Created by Bowen on 2018/7/6.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBCommonViewController.h"

@interface MBTableViewController : MBCommonViewController <UITableViewDelegate, UITableViewDataSource>

//列表控件
@property (nonatomic, strong) UITableView *tableView;

/** 获取最新数据 */
- (void)loadLastData;
/** 获取更多数据 */
- (void)loadMoreData;

/** 添加下拉刷新控件 */
- (void)addRefreshHeader;
/** 移除下拉刷新控件 */
- (void)removeRefreshHeader;
/** 开始下拉刷新 */
- (void)beginHeaderRefresh;
/** 结束下拉刷新 */
- (void)endRefreshHeader;


/** 添加上拉刷新控件 */
- (void)addRefreshFooter;
/** 移除上拉刷新控件 */
- (void)removeRefreshFooter;
/** 结束上拉刷新 */
- (void)endRefreshFooter;
/** 结束上拉刷新，因无数据 */
- (void)endRefreshFooterNoMoreData;
/** 重置上拉刷新 */
- (void)resetRefreshFooterNoMoreData;
/** 结束上拉刷新 */
- (void)setFooterRefreshHidden:(BOOL)isHidden;

@end 
