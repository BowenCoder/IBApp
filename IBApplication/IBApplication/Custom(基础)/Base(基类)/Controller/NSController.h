//
//  NSController.h
//  IBApplication
//
//  Created by Bowen on 2018/7/4.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSHTTPClient.h"

@interface NSController : UIViewController

/** 反向传值使用 */
@property (nonatomic, copy) void (^callback)(id);

/** UI初始化之前运行 */
- (void)onInit;
/** UI初始化 */
- (void)initUI;
/** UI初始化之后运行 */
- (void)initData;
/** 清除缓存 */
- (void)clearCache;

/** 设置背景图片 */
- (void)setBackgroundImage:(UIImage *)image;

@end
