//
//  UIController.h
//  IBApplication
//
//  Created by Bowen on 2018/7/4.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSHTTPClient.h"

@interface UIController : UIViewController

- (void)setBackgroundImage:(UIImage *)image;

- (void)initVC;
- (void)initUI;
- (void)initData;
- (void)clearCache;




@end
