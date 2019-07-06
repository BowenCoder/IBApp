//
//  MBGestureView.h
//  IBApplication
//
//  Created by Bowen on 2019/7/1.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBGestureView : UIView

/**
 该层是否自己处理hitTest 默认NO
 */
@property (nonatomic, assign) BOOL canHandleEvent;

/**
 添加名字，易调试
 */
@property (nonatomic,   copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
