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

@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) BOOL translucent; //YES,为半透明， NO为不透明
@property (nonatomic, assign) BOOL transparent; //透明
@property (nonatomic, assign) UIBarStyle barStyle;

@property (nonatomic, assign) CGFloat alpha; //0~1之间
@property (nonatomic, assign) CGFloat translationY;
@property (nonatomic, strong) UIColor *tintColor; //改不了title颜色，能改titleView颜色
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) NSString *backgroundImgID;


- (instancetype)initWithBarOptions:(IBNaviBarOption)options
                         tintColor:(UIColor *)tintColor
                   backgroundColor:(UIColor *)backgroundColor
                   backgroundImage:(UIImage *)backgroundImage
                   backgroundImgID:(NSString *)backgroundImgID;

- (BOOL)isVisible;

@end
