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

/*! @brief 在外部组装选项按钮item */
- (instancetype)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle items:(NSArray<IBActionItem *> *)items;

/*! @brief 单文本选项快速初始化 */
- (instancetype)initWithTitle:(NSString *)title delegate:(id<IBActionSheetDelegate>)delegate cancelTitle:(NSString *)cancelTitle highlightedTitle:(NSString *)highlightedTitle otherTitles:(NSArray<NSString *> *)otherTitles;

@end
