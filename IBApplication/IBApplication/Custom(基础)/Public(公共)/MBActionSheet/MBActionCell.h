//
//  MBActionCell.h
//  IBApplication
//
//  Created by Bowen on 2018/9/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBColor.h"
#import "MBActionItem.h"

@interface MBActionCell : UITableViewCell

@property (nonatomic, assign) BOOL hideTopLine; ///< 是否隐藏顶部线条
@property (nonatomic, strong) MBActionItem *item;
@property (nonatomic, assign) MBContentAlignment contentAlignment;

+ (NSString *)identifier;

@end
