//
//  IBActionSheet.h
//  IBApplication
//
//  Created by Bowen on 2018/9/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBActionCell.h"

@class IBActionSheet;

@protocol IBActionSheetDelegate <NSObject>

@optional

- (void)actionSheet:(IBActionSheet *)actionSheet selectedIndex:(NSInteger)selectedIndex;

@end


@interface IBActionSheet : UIView

@property (nonatomic, weak) id<IBActionSheetDelegate> delegate; ///< 代理对象
@property (nonatomic, assign) IBContentAlignment contentAlignment; ///< 默认是FSContentAlignmentCenter.

/**
 以item初始化

 @param title 标题
 @param cancelItem 取消按钮，默认为“取消”
 @param items 选项按钮集合
 @return 操作列表
 */
- (instancetype)initWithTitle:(NSString *)title cancelItem:(IBActionItem *)cancelItem items:(NSArray<IBActionItem *> *)items;

/**
 单文本选项快速初始化，此方法只能以代理回调

 @param title 标题
 @param delegate 代理
 @param cancelTitle 取消文案，默认“取消”
 @param highlightedTitle 高亮文案
 @param otherTitles 选项按钮集合
 @return 操作列表
 */
- (instancetype)initWithTitle:(NSString *)title delegate:(id<IBActionSheetDelegate>)delegate cancelTitle:(NSString *)cancelTitle highlightedTitle:(NSString *)highlightedTitle otherTitles:(NSArray<NSString *> *)otherTitles;


- (void)show;

@end

/*
 很新颖
 NS_INLINE IBActionSheet *IBActionSheetMake(NSString *title, IBActionItem *cancelItem, NSArray<IBActionItem *> *items) {
 return [[IBActionSheet alloc] initWithTitle:title cancelItem:cancelItem items:items];
 }
 */
