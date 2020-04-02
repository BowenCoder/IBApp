//
//  MBTabBarItem.m
//  IBApplication
//
//  Created by Bowen on 2018/7/19.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBTabBarItem.h"

@implementation MBTabBarItemModel

- (instancetype)init{
    self = [super init];
    if (self) { // 设置初始默认值
        // 默认标题正常颜色
        self.normalColor = [UIColor grayColor];
        // 默认选中标题颜色
        self.selectColor = [UIColor colorWithRed:19/255.0 green:105/255.0 blue:253/255.0 alpha:1.0];
        // 默认凸出 20
        self.bulgeHeight = 20.0;
        self.pictureWordsMargin = 0.0;
        self.componentMargin = UIEdgeInsetsMake(5, 5, 5, 5);
        self.isRepeatClick = NO;
    }
    return self;
}

@end

@implementation MBTabBarItem

- (instancetype)initWithModel:(MBTabBarItemModel *)itemModel{
    self = [super init];
    if (self) {
        [self setItemModel:itemModel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self itemDidLayoutControl]; // 进行组件布局 （因为需要封装，所以没打算在第一时间进行布局）
}

- (void)itemDidLayoutControl{
    // 开始内部布局
    self.backgroundImageView.frame = self.bounds;
    CGRect iconImgFrame = self.icomImgView.frame;
    CGRect titleFrame = self.titleLabel.frame;
    BOOL isIcomImgViewSize = self.itemModel.icomImgViewSize.width || self.itemModel.icomImgViewSize.height;
    BOOL isTitleLabelSize = self.itemModel.titleLabelSize.width || self.itemModel.titleLabelSize.height;
    // 除去边距后的最大宽度
    CGFloat marginWidth = self.frame.size.width - self.itemModel.componentMargin.left - self.itemModel.componentMargin.right;
    // 进行决策设置大小
    if (isIcomImgViewSize){
        iconImgFrame.size = self.itemModel.icomImgViewSize;
    }else{
        iconImgFrame.size = CGSizeMake(marginWidth, self.frame.size.height * (3/4.0) - self.itemModel.componentMargin.top - 5);
    }
    if (isTitleLabelSize){
        titleFrame.size = self.itemModel.titleLabelSize;
    }else{
        titleFrame.size = CGSizeMake(marginWidth, self.frame.size.height - iconImgFrame.size.height - self.itemModel.componentMargin.bottom);
    }
    // 至此大小已计算完毕，开始布局
    self.titleLabel.hidden = NO;
    self.icomImgView.hidden = NO;
    if (self.title) { // 如果有文字，上图片下文字布局
        iconImgFrame.origin.y = self.itemModel.componentMargin.top;
        iconImgFrame.origin.x = (self.frame.size.width - iconImgFrame.size.width)/2;
        // 图上文下 文label的高度要减去间距
        titleFrame.size.height -= self.itemModel.pictureWordsMargin;
        titleFrame.origin.y = iconImgFrame.origin.y + iconImgFrame.size.height + self.itemModel.pictureWordsMargin;
        titleFrame.origin.x = (self.frame.size.width - titleFrame.size.width)/2;
    } else { // 单图片占满全部
        iconImgFrame.size = CGSizeMake(self.frame.size.width - self.itemModel.componentMargin.left - self.itemModel.componentMargin.right,
                                       self.frame.size.height - self.itemModel.componentMargin.top - self.itemModel.componentMargin.bottom);
        iconImgFrame.origin = CGPointMake(self.itemModel.componentMargin.right, self.itemModel.componentMargin.top);
        self.titleLabel.hidden = YES;
    }
    self.icomImgView.frame = iconImgFrame;
    self.titleLabel.frame = titleFrame;
    
    [self itemDidLayoutBadgeLabel]; // 进行脚标布局
}

- (void)itemDidLayoutBadgeLabel{
    CGFloat centerX = self.icomImgView.center.x + self.icomImgView.image.size.width/2 + self.badgeLabel.frame.size.width/2 - 3;
    CGFloat centerY = self.icomImgView.frame.origin.y + self.badgeLabel.frame.size.height/2;
    self.badgeLabel.center = CGPointMake(centerX, centerY);
    [self bringSubviewToFront:self.badgeLabel];
}

- (void)startAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    switch (self.itemModel.animationStyle) {
        case MBTabBarItemAnimationNone: // 无
            break;
        case MBTabBarItemAnimationSpring: { // 放大放小
            animation.keyPath = @"transform.scale";
            animation.values = @[@1.0,@1.3,@0.9,@1.15,@0.95,@1.02,@1.0];
            animation.duration = 0.6;
            animation.calculationMode = kCAAnimationCubic;
        } break;
        case MBTabBarItemAnimationShake: { // 摇动
            animation.keyPath = @"transform.rotation";
            CGFloat angle = M_PI_4 / 10;
            animation.values = @[@(-angle), @(angle), @(-angle)];
            animation.duration = 0.2f;
        } break;
        case MBTabBarItemAnimationAlpha: { // 透明
            animation.keyPath = @"opacity";
            animation.values = @[@1.0,@0.7,@0.5,@0.7,@1.0];
            animation.duration = 0.6;
        } break;
        default:
            break;
    }
    [self.layer addAnimation:animation forKey:nil];
}

- (void)setItemModel:(MBTabBarItemModel *)itemModel{
    _itemModel = itemModel;
    self.title = _itemModel.itemTitle;
    self.normalImage = [UIImage imageNamed:_itemModel.normalImageName];
    self.selectImage = [UIImage imageNamed:_itemModel.selectImageName];
    self.normalColor = _itemModel.normalColor;
    self.selectColor = _itemModel.selectColor;
    self.normalTintColor = _itemModel.normalTintColor;
    self.selectTintColor = _itemModel.selectTintColor;
    self.normalBackgroundColor = _itemModel.normalBackgroundColor;
    self.selectBackgroundColor = _itemModel.selectBackgroundColor;
    CGRect itemFrame = self.frame;
    itemFrame.size = _itemModel.itemSize;
    self.frame = itemFrame;
    self.badge = _itemModel.badge;
    self.isSelect = self.isSelect;
}

- (void)setIsSelect:(BOOL)isSelect{
    _isSelect = isSelect;
    if (_isSelect) { // 是选中
        self.icomImgView.image = self.selectImage;
        self.titleLabel.textColor = self.selectColor;
        // 如果有设置tintColor，那么就选中图片后将图片渲染成TintColor
        if (self.selectTintColor) {
            self.icomImgView.image = [self.icomImgView.image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
            [self.icomImgView setTintColor:self.selectTintColor];
        }
        [UIView animateWithDuration:0.25 animations:^{
            if (self.selectBackgroundColor) {
                self.backgroundColor = self.selectBackgroundColor;
            }else{
                self.backgroundColor = [UIColor clearColor];
            }
        }];
    } else {
        self.icomImgView.image = self.normalImage;
        self.titleLabel.textColor = self.normalColor;
        // 如果有设置tintColor，那么未选中将图片渲染成TintColor
        if (self.normalTintColor) {
            self.icomImgView.image = [self.icomImgView.image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
            [self.icomImgView setTintColor:self.normalTintColor];
        }
        [UIView animateWithDuration:0.25 animations:^{
            if (self.normalBackgroundColor) {
                self.backgroundColor = self.normalBackgroundColor;
            } else {
                self.backgroundColor = [UIColor clearColor];
            }
        }];
    }
    self.titleLabel.text = self.title;
}

- (void)setBadge:(NSString *)badge{
    _badge = badge;
    if (_badge) {
        self.badgeLabel.badgeValue = _badge;
    }
}

#pragma mark - 懒加载
- (MBTabBarBadge *)badgeLabel{
    if (!_badgeLabel) {
        _badgeLabel = [[MBTabBarBadge alloc] init];
        [self addSubview:_badgeLabel];
    }
    return _badgeLabel;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setContentMode:UIViewContentModeTop];
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}
- (UIImageView *)icomImgView{
    if (!_icomImgView) {
        _icomImgView = [[UIImageView alloc] init];
        _icomImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_icomImgView];
    }
    return _icomImgView;
}
- (UIImageView *)backgroundImageView{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        [self addSubview:_backgroundImageView];
    }
    return _backgroundImageView;
}



@end
