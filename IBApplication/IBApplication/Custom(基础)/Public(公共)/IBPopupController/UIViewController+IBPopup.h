//
//  UIViewController+IBPopup.h
//  IBPopup
//
//  Created by Bowen on 2018/8/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IBPopupController;

@interface UIViewController (IBPopup)

/**
 Content size of popup in portrait orientation.
 */
@property (nonatomic, assign) IBInspectable CGSize contentSizeInPopup;

/**
 Content size of popup in landscape orientation.
 */
@property (nonatomic, assign) IBInspectable CGSize landscapeContentSizeInPopup;

/**
 Popup controller which is containing the view controller.
 Will be nil if the view controller is not contained in any popup controller.
 */
@property (nullable, nonatomic, weak, readonly) IBPopupController *popupController;

@end

NS_ASSUME_NONNULL_END
