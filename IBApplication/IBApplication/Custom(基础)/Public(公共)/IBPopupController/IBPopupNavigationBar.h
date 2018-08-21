//
//  IBPopupNavigationBar.h
//  IBPopup
//
//  Created by Bowen on 2018/8/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IBPopupNavigationBar : UINavigationBar

/**
 Indicates if the navigation bar is draggable to dissmiss the popup.
 Default to YES.
 */
@property (nonatomic, assign) BOOL draggable;

@end

NS_ASSUME_NONNULL_END
