//
//  IBActionCell.h
//  IBApplication
//
//  Created by Bowen on 2018/9/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBColor.h"
#import "IBActionItem.h"

@interface IBActionCell : UITableViewCell

@property (nonatomic, assign) BOOL hideTopLine; ///< 是否隐藏顶部线条
@property (nonatomic, strong) IBActionItem *item;
@property (nonatomic, assign) IBContentAlignment contentAlignment;

+ (NSString *)identifier;

@end
