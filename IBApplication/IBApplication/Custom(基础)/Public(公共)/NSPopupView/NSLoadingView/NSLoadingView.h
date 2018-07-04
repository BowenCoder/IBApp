//
//  NSLoadingView.h
//  IBApplication
//
//  Created by Bowen on 2018/7/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBallLoadingView : UIView

@property (nonatomic, assign) BOOL isAnimating;

- (void)startAnimation;
- (void)stopAnimation;

@end


@interface NSCircleLoadingView : UIView

@property (nonatomic, strong) NSMutableArray *colorArray;
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, assign) BOOL isAnimating;

- (void)startAnimation;
- (void)stopAnimation;

@end


@interface NSTriangleLoadingView : UIView

@property (nonatomic, assign) BOOL isAnimating;

- (void)startAnimation;
- (void)stopAnimation;

@end

