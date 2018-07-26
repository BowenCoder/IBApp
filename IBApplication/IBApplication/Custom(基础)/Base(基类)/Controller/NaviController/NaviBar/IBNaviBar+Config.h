//
//  IBNaviBar+Config.h
//  IBApplication
//
//  Created by Bowen on 2018/7/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBNaviBar.h"
#import "IBNaviConfig.h"

@interface UIViewController (Config)

@property (nonatomic, strong) IBNaviConfig *config;

- (CGRect)barFrameForNavigationBar:(UINavigationBar *)navigationBar;

@end

@interface UIToolbar (Config)

- (void)updateToolBarConfig:(IBNaviConfig *)config;

@end
