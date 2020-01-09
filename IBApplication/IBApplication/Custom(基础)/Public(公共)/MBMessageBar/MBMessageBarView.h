//
//  MBMessageBarView.h
//  IBApplication
//
//  Created by Bowen on 2020/1/6.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBMessageBarStyle.h"

@class MBMessageBarView;

NS_ASSUME_NONNULL_BEGIN

@interface MBMessageBarView : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, weak) id<MBMessageBarStyleProtocol> style;

@property (nonatomic, assign) MBMessageBarStyleType messageType;

@property (nonatomic, assign) MBMessageBarPosition position;

@property (nonatomic, copy) void(^onClickCallback)(void);

@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;


- (void)setupView;

@end

NS_ASSUME_NONNULL_END
