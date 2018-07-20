//
//  IBNaviConfig.h
//  IBApplication
//
//  Created by Bowen on 2018/7/14.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IBNaviConfig : NSObject

@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) BOOL translucent; //半透明
@property (nonatomic, assign) BOOL transparent; //透明

@property (nonatomic, assign) UIBarStyle barStyle;

@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) NSString *backgroundImageID;

@end
