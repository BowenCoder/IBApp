//
//  IBPopupLeftBarItem.h
//  IBPopup
//
//  Created by Bowen on 2018/8/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, IBPopupLeftBarItemType) {
    IBPopupLeftBarItemCross,
    IBPopupLeftBarItemArrow
};

@interface IBPopupLeftBarItem : UIBarButtonItem

@property (nonatomic, assign) IBPopupLeftBarItemType type;

- (instancetype)initWithTarget:(id)target action:(SEL)action;
- (void)setType:(IBPopupLeftBarItemType)type animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
