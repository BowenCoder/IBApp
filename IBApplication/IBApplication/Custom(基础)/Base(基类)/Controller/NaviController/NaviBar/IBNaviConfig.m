//
//  IBNaviConfig.m
//  IBApplication
//
//  Created by Bowen on 2018/7/14.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBNaviConfig.h"

@implementation IBNaviConfig

- (instancetype)init {
    return [self initWithBarOptions:IBNaviBarOptionDefault
                          tintColor:nil
                    backgroundColor:nil
                    backgroundImage:nil
                    backgroundImgID:nil];
}

- (instancetype)initWithBarOptions:(IBNaviBarOption)options
                         tintColor:(UIColor *)tintColor
                   backgroundColor:(UIColor *)backgroundColor
                   backgroundImage:(UIImage *)backgroundImage
                   backgroundImgID:(NSString *)backgroundImgID {
    if (self = [super init]) {
        _hidden = (options & IBNaviBarOptionHidden) > 0;
        _barStyle = (options & IBNaviBarOptionBlack) > 0 ? UIBarStyleBlack : UIBarStyleDefault;
        if (!tintColor) {
            tintColor = _barStyle == UIBarStyleBlack ? [UIColor whiteColor] : [UIColor blackColor];
        }
        _tintColor = tintColor;
        
        if (_hidden) return self;
        
        _transparent = (options & IBNaviBarOptionTransparent) > 0;
        if (_transparent) return self;
        
        _translucent = (options & IBNaviBarOptionOpaque) == 0;
        
        if ((options & IBNaviBarOptionImage) > 0 && backgroundImage) {
            _backgroundImage = backgroundImage;
            _backgroundImgID = backgroundImgID;
        } else if (options & IBNaviBarOptionColor){
            _backgroundColor = backgroundColor;
        }
        _alpha = 1.0;
        _translationY = 0.0;
    }
    return self;
}

- (BOOL)isVisible {
    return !self.hidden && !self.transparent;
}

@end
