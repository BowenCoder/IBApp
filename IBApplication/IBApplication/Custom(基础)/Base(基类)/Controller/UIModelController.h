//
//  UIModelController.h
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UICommonController.h"

@interface UIModelController : UICommonController

/** 开启键盘frame改变通知 */
@property (nonatomic, assign) BOOL openKeyboard;

- (void)goLogin;

@end
