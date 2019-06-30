//
//  UITableView+Extension.m
//  TableView
//
//  Created by Bowen on 2019/4/21.
//  Copyright © 2019 inke. All rights reserved.
//

#import "UITableView+Extension.h"

@implementation UITableView (Extension)

- (void)mb_deleteRowAtIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation {
    NSUInteger sectionCount = [self numberOfSections];
    if (indexPath.section >= sectionCount) {
#if DEBUG
        NSAssert(nil, @" - (void)ik_deleteRowAtIndexPath, section 越界 ");
#else
        return;
#endif
    }
    
    NSUInteger rowCount = [self numberOfRowsInSection:indexPath.section];
    if (indexPath.row >= rowCount) {
#if DEBUG
        NSAssert(nil, @" - (void)ik_deleteRowAtIndexPath, row 越界 ");
#else
        return;
#endif
    }
    
    if (rowCount > 1) {
        [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    } else {
        if ( [self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)] ) {
            NSInteger remindSection = [self.dataSource numberOfSectionsInTableView:self];
            if (remindSection == sectionCount) {
                [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
            } else {
                NSIndexSet *set = [NSIndexSet indexSetWithIndex:indexPath.section];
                [self deleteSections:set withRowAnimation:animation];
            }
        } else {
            [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
        }
    }
}

- (void)mb_deleteRow:(NSUInteger)row inSection:(NSUInteger)section animation:(UITableViewRowAnimation)animation {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self mb_deleteRowAtIndexPath:indexPath animation:animation];
}

- (void)mb_insertRowsAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    if (nil == indexPath) return;
    NSInteger beforeSectionNumber = [self numberOfSections];
    
    if (indexPath.section < beforeSectionNumber) {
        [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    } else if (indexPath.section == beforeSectionNumber) {
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:indexPath.section];
        [self insertSections:set withRowAnimation:animation];
    } else {
#if DEBUG
        NSAssert(nil, @"- (void)ik_insertRowsAtIndexPath:, section 越界 ");
#else
        return;
#endif
    }
}

- (void)mb_insertRow:(NSUInteger)row inSection:(NSUInteger)section animation:(UITableViewRowAnimation)animation {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self mb_insertRowsAtIndexPath:indexPath withRowAnimation:animation];
}

@end
