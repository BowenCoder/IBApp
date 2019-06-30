//
//  UITableView+Extension.h
//  TableView
//
//  Created by Bowen on 2019/4/21.
//  Copyright © 2019 inke. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (Extension)

- (void)mb_deleteRowAtIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation;
- (void)mb_deleteRow:(NSUInteger)row inSection:(NSUInteger)section animation:(UITableViewRowAnimation)animation;

- (void)mb_insertRowsAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (void)mb_insertRow:(NSUInteger)row inSection:(NSUInteger)section animation:(UITableViewRowAnimation)animation;

@end

NS_ASSUME_NONNULL_END
