//
//  UIViewController+Alert.h
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^OnClickHandler) (NSInteger buttonIndex);
typedef void(^TFHandle)(UITextField *field, NSInteger index);

@interface UIViewController (Alert) <UIAlertViewDelegate,UIActionSheetDelegate>

/**
警示框

 @param title 标题
 @param message 描述
 @param others 第一个元素为取消按钮
 @param animated 动画效果
 @param click 点击回调
 */
- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                    others:(NSArray<NSString *> *)others
                  animated:(BOOL)animated
                    action:(OnClickHandler)click;

/**
 操作表

 @param title 标题
 @param message 描述
 @param destructive 红色按钮
 @param others 第一个元素为取消按钮
 @param animated 动画效果
 @param click 点击回调
 */
- (void)showActionSheetWithTitle:(NSString *)title
                         message:(NSString *)message
                     destructive:(NSString *)destructive
                          others:(NSArray <NSString *> *)others
                    animated:(BOOL)animated
                      action:(OnClickHandler)click;

/**
 带有文本框的警示框

 @param title 标题
 @param message 描述
 @param others 第一个元素为取消按钮
 @param number 文本框数
 @param handle 文本回调
 @param animated 动画效果
 @param click 点击回调
 */
- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                    others:(NSArray<NSString *> *)others
                  tfNumber:(NSInteger)number
                  tfHandle:(TFHandle)handle
                  animated:(BOOL)animated
                    action:(OnClickHandler)click;

@end
