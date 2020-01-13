//
//  MBEmptyView.m
//  IBApplication
//
//  Created by Bowen on 2018/7/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "MBEmptyView.h"
#import "Masonry.h"
#import "IBColor.h"

@interface MBEmptyView ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, copy)  void(^reload)(void);

@end

@implementation MBEmptyView

#pragma mark - life cycle

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                       detail:(NSString *)detail
                    imageName:(NSString *)name
                       reload:(void(^)(void))reload {
    
    if (self = [super initWithFrame:frame]) {
        _title     = title;
        _detail    = detail;
        _imageName = name;
        _reload    = reload;
        [self setupView];
    }
    return self;
}

- (void)setupView {

    self.backgroundColor = [UIColor whiteColor];

    [self addSubview:self.containerView];
    [self.containerView addSubview:self.imgView];
    [self.containerView addSubview:self.titleLabel];
    [self.containerView addSubview:self.detailLabel];
    [self makeConstraints];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
    [self addGestureRecognizer:tap];
}

- (void)makeConstraints {

    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.left.right.mas_equalTo(self);
    }];
    
    if (self.imgView.image) {
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(200);
            make.centerX.equalTo(self.containerView);
            make.top.mas_equalTo(self.containerView).offset(10);
        }];
    }
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.top.equalTo(self.imgView.mas_bottom).offset(10);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.bottom.equalTo(self.containerView).offset(-10);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
    }];
    
}

- (void)click {
    if (self.reload) {
        [self removeFromSuperview];
        self.reload();
    }
}

#pragma mark - getter and setter

- (UIView*)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    return _containerView;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.backgroundColor = [UIColor whiteColor];
        _imgView.image = [UIImage imageNamed:_imageName];
    }
    return _imgView;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [IBColor colorWithHexString:@"#707070"];
        _titleLabel.text = _title;
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 40;
    }
    return _titleLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textColor = [IBColor colorWithHexString:@"#8a8a8a"];
        _detailLabel.text = _detail;
        _detailLabel.backgroundColor = [UIColor whiteColor];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.numberOfLines = 0;
        _detailLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 40;
    }
    return _detailLabel;
}

@end
