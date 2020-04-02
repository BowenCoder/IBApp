//
//  MBTabBarItem.h
//  IBApplication
//
//  Created by Bowen on 2018/7/19.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBTabBarBadge.h"

// 凸出后的形状
typedef NS_ENUM(NSInteger, MBTabBarBulgeStyle) {
    MBTabBarBulgeNormal = 0,  // 无 默认
    MBTabBarBulgeCircular,    // 圆形
    MBTabBarBulgeSquare       // 方形
};

// 点击触发时候的动画效果
typedef NS_ENUM(NSInteger, MBTabBarItemAnimationStyle) {
    MBTabBarItemAnimationNone,     // 无 默认
    MBTabBarItemAnimationSpring,   // 放大放小弹簧效果
    MBTabBarItemAnimationShake,    // 摇动动画效果
    MBTabBarItemAnimationAlpha     // 透明动画效果
};

@interface MBTabBarItemModel : NSObject

#pragma mark - 标题控制类
// item的标题
@property (nonatomic, copy) NSString *itemTitle;
// 默认标题颜色 默认灰色
@property (nonatomic, strong) UIColor *normalColor;
// 选中标题颜色 默认AxcAE_TabBarItemSlectBlue
@property (nonatomic, strong) UIColor *selectColor;

#pragma mark - 图片控制类
// 选中后的图片名称
@property (nonatomic, copy) NSString *selectImageName;
// 正常的图片名称
@property (nonatomic, copy) NSString *normalImageName;
// 默认的图片tintColor
@property (nonatomic, strong) UIColor *normalTintColor;
// 选中的图片tintColor
@property (nonatomic, strong) UIColor *selectTintColor;

#pragma mark - item背景控制类
// 默认的按钮背景Color 默认无
@property (nonatomic, strong) UIColor *normalBackgroundColor;
// 选中的按钮背景Color 默认无
@property (nonatomic, strong) UIColor *selectBackgroundColor;

#pragma mark - item附加控制类
// 凸出形变类型
@property (nonatomic, assign) MBTabBarBulgeStyle bulgeStyle;
// 凸出高于TabBar多高 默认20
@property (nonatomic, assign) CGFloat bulgeHeight;
// 突出后圆角 默认0  如果是圆形的圆角，则会根据设置的ItemSize最大宽度自动裁切，设置后将按照此参数进行裁切
@property (nonatomic, assign) CGFloat bulgeRoundedCorners;
// item大小
@property (nonatomic, assign) CGSize itemSize;
// 角标内容
@property (nonatomic, strong) NSString *badge;

#pragma mark - item内部组件控制类
// titleLabel大小 有默认值
@property (nonatomic, assign) CGSize titleLabelSize;
// icomImgView大小 有默认值
@property (nonatomic, assign) CGSize icomImgViewSize;
// 所有组件距离item边距 默认 UIEdgeInsetsMake(5, 5, 5, 5)
@property (nonatomic, assign) UIEdgeInsets componentMargin;
// 图片文字的间距 默认 0
@property (nonatomic, assign) CGFloat pictureWordsMargin;

#pragma mark - item动画控制类
// 点击触发后的动画效果
@property (nonatomic, assign) MBTabBarItemAnimationStyle animationStyle;
// 是否允许重复点击触发动画 默认NO
@property (nonatomic, assign) BOOL isRepeatClick;

@end


@interface MBTabBarItem : UIControl

// 模型构造器
@property (nonatomic, strong) MBTabBarItemModel *itemModel;
// 角标内容
@property (nonatomic, strong) NSString *badge;
// item的所在索引
@property (nonatomic, assign) NSInteger itemIndex;
// 选中状态
@property (nonatomic, assign) BOOL isSelect;
// 标题
@property (nonatomic, copy) NSString *title;
// 默认标题颜色
@property (nonatomic, strong) UIColor *normalColor;
// 选中标题颜色
@property (nonatomic, strong) UIColor *selectColor;
// 默认的Image
@property (nonatomic, strong) UIImage *normalImage;
// 选中的Image
@property (nonatomic, strong) UIImage *selectImage;
// 默认的图片tintColor
@property (nonatomic, strong) UIColor *normalTintColor;
// 选中的图片tintColor
@property (nonatomic, strong) UIColor *selectTintColor;
// 默认的按钮背景Color,默认无
@property (nonatomic, strong) UIColor *normalBackgroundColor;
// 选中的按钮背景Color,默认无
@property (nonatomic, strong) UIColor *selectBackgroundColor;

// 标题Label
@property (nonatomic, strong) UILabel *titleLabel;
// imageView(无标题则居中)
@property (nonatomic, strong) UIImageView *icomImgView;
// 角标Label
@property (nonatomic, strong) MBTabBarBadge *badgeLabel;
// 单个item的背景图
@property (nonatomic, strong) UIImageView *backgroundImageView;

// 构造
- (instancetype)initWithModel:(MBTabBarItemModel *)itemModel;

// 开始执行动画
- (void)startAnimation;

// 重新开始布局
- (void)itemDidLayoutControl;


@end
