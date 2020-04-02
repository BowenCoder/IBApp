//
//  MBTabBarBadge.h
//  IBApplication
//
//  Created by Bowen on 2018/7/19.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBTabBarBadge : UILabel

// 文字或者数字(为1时是个点，为0时隐藏)
@property (nonatomic, strong) NSString *badgeValue;

@end
