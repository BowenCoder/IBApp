//
//  MBBlurImageView.m
//  IBApplication
//
//  Created by Bowen on 2019/8/23.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBBlurImageView.h"
#import "Masonry.h"

@interface MBBlurImageView ()

@property (nonatomic, strong) UIVisualEffectView *effectView;

@end

@implementation MBBlurImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupEffectView];
    }
    return self;
}

- (void)setupEffectView
{
    [self addSubview:self.effectView];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setEffectStyle:(UIBlurEffectStyle)effectStyle
{
    _effectStyle = effectStyle;
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:effectStyle];
    self.effectView.effect = effect;
}

- (UIVisualEffectView *)effectView {
    if(!_effectView){
        _effectView = [[UIVisualEffectView alloc] init];
    }
    return _effectView;
}

@end
