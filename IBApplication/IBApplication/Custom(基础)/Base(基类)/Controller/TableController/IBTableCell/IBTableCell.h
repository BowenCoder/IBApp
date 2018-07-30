//
//  IBTableCell.h
//  IBApplication
//
//  Created by Bowen on 2018/7/30.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IBTableCellSeparatorStyle){
    IBTableCellSeparatorNone,                   // 无分割线
    IBTableCellSeparatorTop,                    // 顶部分割线（屏幕宽）
    IBTableCellSeparatorBottom,                 // 底部分割线（屏幕宽）
    IBTableCellSeparatorBoth                    // 既有顶部分割线也有底部分割线，默认（屏幕宽）
};

@interface IBTableCell : UITableViewCell

/** 分割线的类型 */
@property (nonatomic, assign) IBTableCellSeparatorStyle separatorStyle;
/** 分割线的颜色 */
@property (nonatomic, strong) UIColor *seperatorColor;

+ (NSString *)identifier;

+ (instancetype)tableCellWithTableView:(UITableView *)tableView;

- (void)setupCell;

@end
