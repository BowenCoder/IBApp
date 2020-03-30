//
//  UIResponder+Ext.h
//  IBApplication
//
//  Created by Bowen on 2020/3/30.
//  Copyright © 2020 BowenCoder. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (Ext)

/// 系统自己的isFirstResponder有延迟，这里手动记录UIResponder是否isFirstResponder
@property (nonatomic, assign) BOOL fb_isFirstResponder;

@end

NS_ASSUME_NONNULL_END
