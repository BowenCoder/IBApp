//
//  MBDropDownPanelView.h
//  IBApplication
//
//  Created by Bowen on 2020/9/3.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBDropDownPanelView : UIView

- (void)showContentView:(UIView *)contentView inView:(UIView *)inView;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
