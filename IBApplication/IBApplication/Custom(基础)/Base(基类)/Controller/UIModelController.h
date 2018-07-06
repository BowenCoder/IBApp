//
//  UIModelController.h
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIController.h"

@interface UIModelController : UIController

/** 开启键盘frame改变通知 */
@property (nonatomic, assign) BOOL openKeyListener;

- (void)enterLoginVC;

- (void)pageLoad:(NSString *)url params:(NSDictionary *)params success:(NSHTTPClientSuccess)success failure:(NSHTTPClientError)failure isGet:(BOOL)isGet;

@end
