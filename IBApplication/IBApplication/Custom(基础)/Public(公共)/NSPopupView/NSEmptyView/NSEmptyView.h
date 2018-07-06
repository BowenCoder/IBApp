//
//  NSEmptyView.h
//  IBApplication
//
//  Created by Bowen on 2018/7/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSEmptyView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                       detail:(NSString *)detail
                    imageName:(NSString *)name
                       reload:(void(^)(void))reload;

@end
