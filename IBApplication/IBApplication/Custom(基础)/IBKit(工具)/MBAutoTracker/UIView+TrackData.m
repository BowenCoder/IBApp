//
//  UIView+TrackData.m
//  IBApplication
//
//  Created by Bowen on 2020/1/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "UIView+TrackData.h"

@implementation UIView (TrackData)

+ (NSString *)viewPathForSender:(id)sender {
    NSString *viewPath = @"";
    if ([sender isKindOfClass:[UIView class]]) {
        viewPath = [NSString stringWithFormat:@"%@-%@", [self parentPathForComponent:sender], [self pathForComponent:sender]];
    }
    return viewPath;
}

+ (NSString *)parentPathForComponent:(id)component {
    id parent = [component nextResponder];
    if ([parent isKindOfClass:[UIView class]]) {
        NSString *a = [self parentPathForComponent:parent];
        NSString *b = [self pathForComponent:parent];
        return [NSString stringWithFormat:@"%@-%@", a, b];
    } else if ([parent isKindOfClass:[UIViewController class]]) {
        return NSStringFromClass([parent class]);
    } else {
        return nil;
    }
}

+ (NSString *)indexForComponent:(id)component {
    if ([component isKindOfClass:[UITableViewCell class]]) {
        UITableView *tableView = [self targetForView:component withClass:[UITableView class]];
        if (tableView) {
            NSIndexPath *indexPath = [tableView indexPathForCell:component];
            return [NSString stringWithFormat:@"%ld:%ld", (long)indexPath.section, (long)indexPath.row];
        }
    } else if ([component isKindOfClass:[UICollectionViewCell class]]) {
        UICollectionView *collectionView = [self targetForView:component withClass:[UICollectionView class]];
        if (collectionView) {
            NSIndexPath *indexPath = [collectionView indexPathForCell:component];
            return [NSString stringWithFormat:@"%ld:%ld", (long)indexPath.section, (long)indexPath.item];
        }
    }
    
    id parent = [component nextResponder];
    NSInteger index = 0;
    if ([parent isKindOfClass:[UIViewController class]]) {
        return @"0";
    } else if ([parent isKindOfClass:[UIView class]]) {
        UIView *view = parent;
        for (id subview in view.subviews) {
            if ([subview isKindOfClass:[component class]]) {
                if (subview != component) {
                    index++;
                } else {
                    break;
                }
            }
        }
    } else {
        index = -1;
    }
    return @(index).stringValue;
}

+ (NSString *)pathForComponent:(id)component {
    return [NSString stringWithFormat:@"%@[%@]", NSStringFromClass([component class]), [self indexForComponent:component]];
}

+ (id)targetForView:(UIView *)view withClass:(Class)targetClass {
    UIResponder *responder = view;
    BOOL isFound = NO;
    while (![responder isKindOfClass:targetClass]) {
        responder = [responder nextResponder];
        isFound = YES;
    }
    if (isFound) {
        return responder;
    } else {
        return nil;
    }
}

@end
