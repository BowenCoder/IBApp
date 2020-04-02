//
//  IBTableCell.h
//  IBApplication
//
//  Created by Bowen on 2018/7/30.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MBTableViewCellSeparatorType) {
    MBTableViewCellSeparatorNone,                   // 无分割线
    MBTableViewCellSeparatorTop,                    // 顶部分割线（屏幕宽）
    MBTableViewCellSeparatorBottom,                 // 底部分割线（屏幕宽）
    MBTableViewCellSeparatorBoth                    // 既有顶部分割线也有底部分割线，默认（屏幕宽）
};

@interface MBTableViewCell : UITableViewCell

/** 分割线的类型 */
@property (nonatomic, assign) MBTableViewCellSeparatorType separatorType;
/** 分割线的颜色 */
@property (nonatomic, strong) UIColor *seperatorColor;

+ (NSString *)identifier;

+ (instancetype)tableCellWithTableView:(UITableView *)tableView;

- (void)setupCell;

@end
