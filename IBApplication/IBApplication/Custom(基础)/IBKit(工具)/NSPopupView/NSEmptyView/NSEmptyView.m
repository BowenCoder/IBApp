//
//  NSEmptyView.m
//  IBApplication
//
//  Created by Bowen on 2018/7/3.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSEmptyView.h"
#import "Masonry.h"
#import "NSColor.h"

@interface NSEmptyView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailTitleLabel;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, copy)  void(^reload)(void);

@end

@implementation NSEmptyView

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
        _title = title;
        _detailTitle = detail;
        _imageName = name;
        _reload = reload;
        [self initView];
        [self setupView];
    }
    return self;
}

- (void)initView {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
    [self addGestureRecognizer:tap];
}

- (void)setupView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.imgView];
    [self.containerView addSubview:self.titleLabel];
    [self.containerView addSubview:self.detailTitleLabel];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)click {
    if (self.reload) {
        self.reload();
    }
}

- (void)updateConstraints {
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.center.equalTo(self);
    }];
    
    if (self.imgView.image) {
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containerView).offset(10);
            make.width.height.mas_equalTo(200);
            make.centerX.equalTo(self.containerView);
        }];
    }
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView.mas_bottom).offset(10);
        make.centerX.equalTo(self.containerView);
    }];
    
    [self.detailTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.bottom.equalTo(self.containerView).offset(-10);
        make.centerX.equalTo(self.containerView);
    }];

    [super updateConstraints];
}


#pragma mark - getter and setter

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)setImageName:(NSString *)imageName {
    self.imgView.image = [UIImage imageNamed:imageName];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)setDetailTitle:(NSString *)detailTitle {
    self.detailTitleLabel.text = detailTitle;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

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
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [NSColor colorWithHexString:@"#707070"];
        _titleLabel.text = _title;
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 40;
    }
    return _titleLabel;
}

- (UILabel*)detailTitleLabel {
    if (!_detailTitleLabel) {
        _detailTitleLabel = [[UILabel alloc] init];
        _detailTitleLabel.font = [UIFont systemFontOfSize:14];
        _detailTitleLabel.textColor = [NSColor colorWithHexString:@"#8a8a8a"];
        _detailTitleLabel.text = _detailTitle;
        _detailTitleLabel.backgroundColor = [UIColor whiteColor];
        _detailTitleLabel.textAlignment = NSTextAlignmentCenter;
        _detailTitleLabel.numberOfLines = 0;
        _detailTitleLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 40;
    }
    return _detailTitleLabel;
}

@end
