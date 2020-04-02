//
//  MBModelViewController.h
//  IBApplication
//
//  Created by Bowen on 2020/4/2.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBCommonViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBModelViewController : MBCommonViewController

/**
 *  动态字体的回调函数。
 *
 *  交给子类重写，当系统字体发生变化的时候，会调用这个方法，一些font的设置或者reloadData可以放在里面
 *
 *  @param notification test
 */
- (void)contentSizeCategoryDidChanged:(NSNotification *)notification;


@end

NS_ASSUME_NONNULL_END
