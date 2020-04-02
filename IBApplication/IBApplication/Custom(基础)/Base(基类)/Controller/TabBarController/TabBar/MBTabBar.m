//
//  MBTabBar.m
//  IBApplication
//
//  Created by Bowen on 2018/7/19.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBTabBar.h"
#import "IBMacros.h"
#import "UIMacros.h"

#define MBTabBarTag 10000

@interface MBTabBar ()

@property (nonatomic, strong) NSMutableArray <MBTabBarItem *> *items;
// 上次选择的item
@property (nonatomic, strong) MBTabBarItem *preSelectItem;
// TabBar背景图
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation MBTabBar

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithTabBarItemModels:(NSArray <MBTabBarItemModel *> *)itemModels {
    self = [super init];
    if (self) {
        [self setupView];
        self.itemModels = itemModels;
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.backgroundImageView]; // 添加背景图
}

- (void)setBadge:(NSString *)Badge index:(NSUInteger)index{
    if (index < self.items.count) {
        MBTabBarItem *item = self.items[index];
        item.badge = Badge;
    }else{
        NSException *excp = [NSException exceptionWithName:@"AxcAE_TabBar Error"
                                                    reason:@"设置脚标越界！" userInfo:nil];
        [excp raise]; // 抛出异常
    }
}

- (void)setSelectIndex:(NSInteger)selectIndex animation:(BOOL )animation {
    [self switch_tabBarItemIndex:_selectIndex animation:animation];
}

// 点击的tabbarItem
- (void)click_tabBarItem:(MBTabBarItem *)sender{
    NSInteger clickIndex = sender.tag - MBTabBarTag;
    [self switch_tabBarItemIndex:clickIndex animation:YES];
}

// 切换页面/状态
- (void)switch_tabBarItemIndex:(NSInteger )index animation:(BOOL )animation{
    // 1.切换tabbar的状态
    [self.items enumerateObjectsUsingBlock:^(MBTabBarItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.isSelect = index == idx; // 当前点击的调整选中，其他否定
    }];
    // 动画逻辑
    weakify(self); // 2.通过回调点击事件让代理去执行切换选项卡的任务
    MBTabBarItem *item = self.items[index];
    if (item.itemModel.isRepeatClick) { // 允许重复点击触发动画
        if (animation) [item startAnimation]; // 开始执行设置的动画效果
        if (self.delegate && [self.delegate respondsToSelector:@selector(tabBar:selectIndex:)]) {
            [self.delegate tabBar:weakself selectIndex:index];
        }
    } else {
        if (![self.preSelectItem isEqual:item]) { // 不是上次点击的
            self.preSelectItem = item;
            if (animation) [item startAnimation]; // 开始执行设置的动画效果
            if (self.delegate && [self.delegate respondsToSelector:@selector(tabBar:selectIndex:)]) {
                [self.delegate tabBar:weakself selectIndex:index];
            }
        }
    }
}

#pragma mark - 适配

- (void)layoutSubviews{
    [super layoutSubviews];
    [self viewDidLayoutItems]; // 进行布局 （因为需要封装，所以没打算在第一时间进行布局）
    [self itemDidLayoutBulge];
    [self layoutTabBarSubViews];
}

// 进行item布局
- (void)viewDidLayoutItems{
    CGFloat screenAverageWidth = self.frame.size.width/self.items.count;
    [self.items enumerateObjectsUsingBlock:^(MBTabBarItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect itemFrame = item.frame;
        CGFloat itemHeight = self.frame.size.height;
        if (kIphoneX || itemHeight > 50) {
            itemHeight = 49; // iphoneX高度要小
        }
        BOOL isNoSettingItemSize = !item.itemModel.itemSize.width || !item.itemModel.itemSize.height;
        if (isNoSettingItemSize) { // 没设置则为默认填充模式
            itemFrame.origin.x = idx * screenAverageWidth;
            itemFrame.size = CGSizeMake(screenAverageWidth , itemHeight);
        } else { // 如果设置了大小
            itemFrame.size = item.itemModel.itemSize;
            itemFrame.origin.x = idx * screenAverageWidth + (screenAverageWidth - item.itemModel.itemSize.width)/2;
            itemFrame.origin.y = (itemHeight - item.itemModel.itemSize.height)/2;
        }
        item.frame = itemFrame;
        // 通知Item同时开始计算坐标
        [item itemDidLayoutControl];
    }];
}

- (void)layoutTabBarSubViews{
    // 适配背景图
    self.backgroundImageView.frame = self.frame;
}

// 适配凸出
- (void)itemDidLayoutBulge{
    CGFloat screenAverageWidth = self.frame.size.width/self.items.count;
    [self.items enumerateObjectsUsingBlock:^(MBTabBarItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect itemFrame = item.frame;
        CGFloat sideLength = MAX(itemFrame.size.width, itemFrame.size.height);
        switch (item.itemModel.bulgeStyle) {
            case MBTabBarBulgeNormal:
                break;         // 无 默认
            case MBTabBarBulgeCircular: { // 圆形
                itemFrame.size = CGSizeMake(sideLength, sideLength);
                itemFrame.origin.y = - item.itemModel.bulgeHeight;
                itemFrame.origin.x = idx * screenAverageWidth + (screenAverageWidth - sideLength)/2; // 居中
                item.frame = itemFrame;
                item.layer.masksToBounds = YES;
                if (item.itemModel.bulgeRoundedCorners) {
                    item.layer.cornerRadius = item.itemModel.bulgeRoundedCorners;
                } else {
                    item.layer.cornerRadius = sideLength/2;
                }
            } break;
            case MBTabBarBulgeSquare: { // 方形
                itemFrame.origin.y = - item.itemModel.bulgeHeight;
                itemFrame.origin.x = idx * screenAverageWidth + (screenAverageWidth - itemFrame.size.width)/2; // 居中
                item.frame = itemFrame;
                if (item.itemModel.bulgeRoundedCorners) {
                    item.layer.masksToBounds = YES;
                    item.layer.cornerRadius = item.itemModel.bulgeRoundedCorners;
                }
            } break;
            default:
                break;
        }
        item.frame = itemFrame;
    }];
}

#pragma mark - 常规配置

// 设置items
- (void)setItemModels:(NSArray<MBTabBarItemModel *> *)itemModels {
    _itemModels = itemModels;
    [itemModels enumerateObjectsUsingBlock:^(MBTabBarItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MBTabBarItem *item = [[MBTabBarItem alloc] initWithModel:obj]; // 模型转成实例
        item.itemIndex = idx; // 交付索引
        item.tintColor = self.tintColor;
        item.tag = MBTabBarTag + idx; // 区分Tag
        [item addTarget:self action:@selector(click_tabBarItem:) forControlEvents:UIControlEventTouchUpInside];
        if (!idx) {
            item.isSelect = YES;
        }
        [self addSubview:item];
        [self.items addObject:item];
    }];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.backgroundImageView.backgroundColor = backgroundColor;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = backgroundImage;
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex; // 设置执行Set后实时切换页面
    [self switch_tabBarItemIndex:_selectIndex animation:NO];
}

- (NSArray<MBTabBarItem *> *)tabBarItems { // 对外只读
    return self.items;
}

- (MBTabBarItem *)currentSelectItem { // 直接用只读的属性
    return [self.tabBarItems objectAtIndex:self.selectIndex];
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [UIImageView new];
    }
    return _backgroundImageView;
}

- (NSMutableArray<MBTabBarItem *> *)items {
    if (!_items) {
        _items = @[].mutableCopy;
    }
    return _items;
}


/**
 // 处理点外无法触发响应的BUG，但是iOS11后此方法失效，需要重新继承一个UITabBar去替换掉系统的TabBar然后重写触发才能使用
 // TabBar视图之外之所以无法响应，是因为系统自带TabBar为我的父视图，无法传递响应链，此方法注释废弃
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint myPoint = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, myPoint)) {
                return subView;
            }
        }
    }
    return view;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    __block BOOL isInside = NO;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        isInside = CGRectContainsPoint(obj.bounds, point);
    }];
    return isInside;
}
*/


@end
