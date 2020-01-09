//
//  MBMessageBarManager.h
//  IBApplication
//
//  Created by Bowen on 2020/1/6.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBMessageBarStyle.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBMessageBarManager : UIView

+ (MBMessageBarManager *)sharedInstance;

@property (nonatomic, strong) id<MBMessageBarStyleProtocol> style;
@property (nonatomic, assign) MBMessageBarPosition position;

/// 精简
- (void)showMessage:(NSString *)message callback:(nullable void (^)(void))callback;

/// 默认
- (void)showMessageWithTitle:(nullable NSString *)title message:(NSString *)message image:(nullable UIImage *)iconImage callback:(nullable void (^)(void))callback;

/// 展示时间
- (void)showMessageWithTitle:(nullable NSString *)title message:(NSString *)message image:(nullable UIImage *)iconImage type:(MBMessageBarStyleType)type duration:(CGFloat)duration callback:(nullable void (^)(void))callback;

/// 状态栏是否展示
- (void)showMessageWithTitle:(nullable NSString *)title message:(NSString *)message image:(nullable UIImage *)iconImage type:(MBMessageBarStyleType)type statusBarHidden:(BOOL)statusBarHidden callback:(nullable void (^)(void))callback;

/// 状态栏样式
- (void)showMessageWithTitle:(nullable NSString *)title message:(NSString *)message image:(nullable UIImage *)iconImage type:(MBMessageBarStyleType)type statusBarStyle:(UIStatusBarStyle)statusBarStyle callback:(void (^)(void))callback;

/// 高级定制
- (void)showMessageWithTitle:(nullable NSString *)title message:(NSString *)message image:(nullable UIImage *)iconImage type:(MBMessageBarStyleType)type duration:(CGFloat)duration statusBarHidden:(BOOL)statusBarHidden statusBarStyle:(UIStatusBarStyle)statusBarStyle callback:(void (^)(void))callback;

- (void)hideAllAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
