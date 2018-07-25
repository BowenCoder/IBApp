//
//  IBNaviConfig.h
//  IBApplication
//
//  Created by Bowen on 2018/7/14.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, IBNaviBarOption) {
    IBNaviBarOptionShow   = 0,
    IBNaviBarOptionHidden = 1,
    
    IBNaviBarOptionLight = 0 << 4,
    IBNaviBarOptionBlack = 1 << 4,
    
    IBNaviBarOptionTranslucent = 0 << 8,
    IBNaviBarOptionOpaque      = 1 << 8,
    IBNaviBarOptionTransparent = 2 << 8,
    
    IBNaviBarOptionNone  = 0 << 16,
    IBNaviBarOptionColor = 1 << 16,
    IBNaviBarOptionImage = 2 << 16,
    
    IBNaviBarOptionDefault = 0,
};


@interface IBNaviConfig : NSObject

@property (nonatomic, readonly, assign) BOOL hidden;
@property (nonatomic, readonly, assign) BOOL translucent; //半透明
@property (nonatomic, readonly, assign) BOOL transparent; //透明
@property (nonatomic, readonly, assign) UIBarStyle barStyle;

@property (nonatomic, readonly, assign) CGFloat alpha;
@property (nonatomic, readonly, strong) UIColor *tintColor;
@property (nonatomic, readonly, strong) UIColor *backgroundColor;
@property (nonatomic, readonly, strong) UIImage *backgroundImage;
@property (nonatomic, readonly, strong) NSString *backgroundImgID;


- (instancetype)initWithBarOptions:(IBNaviBarOption)options
                         tintColor:(UIColor *)tintColor
                   backgroundColor:(UIColor *)backgroundColor
                   backgroundImage:(UIImage *)backgroundImage
                   backgroundImgID:(NSString *)backgroundImgID;

- (BOOL)isVisible;

@end
