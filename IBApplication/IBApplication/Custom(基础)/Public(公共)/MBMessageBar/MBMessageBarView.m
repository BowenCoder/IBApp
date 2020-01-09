//
//  MBMessageBarView.m
//  IBApplication
//
//  Created by Bowen on 2020/1/6.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBMessageBarView.h"

CGFloat const kMBMessageBarViewIconImageSize = 36.f;
CGFloat const kMBMessageBarViewPadding = 8.f;
CGFloat const kMBMessageBarViewRadius = 5.f;

@interface MBMessageBarView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, assign) CGSize titleSize;
@property (nonatomic, assign) CGSize messageSize;

@end

@implementation MBMessageBarView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)setupView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeDeviceOrientation:) name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    self.frame = [self messageBarframe];
    self.backgroundColor = [self backgroundViewColor];
    [self addSubview:self.iconImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.messageLabel];
}

- (CGRect)messageBarframe
{
    CGFloat x, y, width, height;
    
    switch (self.position) {
        case MBMessageBarPositionDefault:
            x = 0.0;
            y = 0.0;
            width = [self screenWidth];
            height = [self statusBarHeight];
            break;
        case MBMessageBarPositionBelowStatusBar:
            x = kMBMessageBarViewPadding;
            y = [self statusBarOffset];
            width = [self screenWidth] - 2 * kMBMessageBarViewPadding;
            height = 0.0;
            break;
        default:
            break;
    }
    
    CGFloat imageSize = self.iconImageView.image ? kMBMessageBarViewIconImageSize : 0;
    CGFloat imageWidth = imageSize ? imageSize + kMBMessageBarViewPadding : 0;
    CGFloat imageHeight = imageSize + 2 * kMBMessageBarViewPadding;
    
    CGFloat textWidth = width - imageWidth - 2 * kMBMessageBarViewPadding;
    self.titleSize = [self sizeForString:self.title font:[self titleFont] maxWidth:textWidth];
    self.messageSize = [self sizeForString:self.message font:[self messageFont] maxWidth:textWidth];
    
    CGFloat textHeight = self.messageSize.height + 2 * kMBMessageBarViewPadding;
    if (self.titleSize.height) {
        textHeight += self.titleSize.height + kMBMessageBarViewPadding/2;
    }
    
    height += imageHeight > textHeight ? imageHeight : textHeight;
    
    return CGRectMake(x, y, width, height);
}

- (CGFloat)screenWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}

- (CGFloat)statusBarOffset
{
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (CGFloat)statusBarHeight
{
    if (self.statusBarHidden || self.position == MBMessageBarPositionBelowStatusBar) {
        return 0;
    }
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
        
    if (self.iconImageView.image) {
        CGFloat imageX = kMBMessageBarViewPadding;
        CGFloat imageY = (self.frame.size.height)/2 - kMBMessageBarViewIconImageSize/2 + [self statusBarHeight]/2;
        CGFloat imageSize = kMBMessageBarViewIconImageSize;
        self.iconImageView.frame = CGRectMake(imageX, imageY, imageSize, imageSize);
    }
    
    if (self.title && self.message) {
        CGFloat titleX = CGRectGetMaxX(self.iconImageView.frame) + kMBMessageBarViewPadding;
        CGFloat titleY = kMBMessageBarViewPadding + [self statusBarHeight];
        self.titleLabel.frame = CGRectMake(titleX, titleY, self.titleSize.width, self.titleSize.height);
        CGFloat messageY = CGRectGetMaxY(self.titleLabel.frame) + kMBMessageBarViewPadding/2;
        self.messageLabel.frame = CGRectMake(titleX, messageY, self.messageSize.width, self.messageSize.height);
    }
    
    if (!self.title && self.message && self.iconImageView.image) {
        CGFloat messageX = CGRectGetMaxX(self.iconImageView.frame) + kMBMessageBarViewPadding;
        CGFloat messageY = (self.frame.size.height)/2 - self.messageSize.height/2 + [self statusBarHeight]/2;
        self.messageLabel.frame = CGRectMake(messageX, messageY, self.messageSize.width, self.messageSize.height);
    }
    
    if (!self.title && self.message && !self.iconImageView.image) {
        CGFloat messageX = (self.frame.size.width)/2 - self.messageSize.width/2;
        CGFloat messageY = (self.frame.size.height)/2 - self.messageSize.height/2 + [self statusBarHeight]/2;
        self.messageLabel.frame = CGRectMake(messageX, messageY, self.messageSize.width, self.messageSize.height);
    }

}

#pragma mark - MBMessageBarStyleProtocol

- (UIColor *)backgroundViewColor
{
    if (self.style && [self.style respondsToSelector:@selector(backgroundColorForMessageType:)]) {
        return [self.style backgroundColorForMessageType:self.messageType];
    }
    return nil;
}

- (UIImage *)iconViewImage
{
    if (self.style && [self.style respondsToSelector:@selector(iconImageForMessageType:)]) {
        return [self.style iconImageForMessageType:self.messageType];
    }
    return nil;
}

- (UIFont *)titleFont
{
    if (self.style && [self.style respondsToSelector:@selector(titleFontForMessageType:)]) {
        return [self.style titleFontForMessageType:self.messageType];
    }
    return [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
}

- (UIFont *)messageFont
{
    if (self.style && [self.style respondsToSelector:@selector(messageFontForMessageType:)]) {
        return [self.style messageFontForMessageType:self.messageType];
    }
    return [UIFont systemFontOfSize:15];
}

- (UIColor *)titleColor
{
    if (self.style && [self.style respondsToSelector:@selector(titleColorForMessageType:)]) {
        return [self.style titleColorForMessageType:self.messageType];
    }
    return [UIColor whiteColor];
}

- (UIColor *)messageColor
{
    if (self.style && [self.style respondsToSelector:@selector(messageColorForMessageType:)]) {
        return [self.style messageColorForMessageType:self.messageType];
    }
    return [UIColor whiteColor];
}

#pragma mark - notification

- (void)didChangeDeviceOrientation:(NSNotification *)notification
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [self screenWidth] - 2*self.frame.origin.x, self.frame.size.height);
    [self setNeedsDisplay];
}

#pragma mark - util

- (CGSize)sizeForString:(NSString *)content font:(UIFont *)font maxWidth:(CGFloat) maxWidth{
    if (!content || content.length == 0) {
        return CGSizeMake(0, 0);
    }
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    CGSize size = [content boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSParagraphStyleAttributeName : paragraphStyle,
                                                  NSFontAttributeName : font}
                                        context:nil].size;
    
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

#pragma mark - getter

- (void)setPosition:(MBMessageBarPosition)position
{
    _position = position;
    if (position == MBMessageBarPositionBelowStatusBar) {
        self.layer.cornerRadius = kMBMessageBarViewRadius;
        self.layer.masksToBounds = YES;
    }
}

- (void)setTitle:(NSString *)title
{
    if ([title isEqualToString:@""]) {
        title = nil;
    }
    _title = title;
    self.titleLabel.text = title;
}

- (void)setMessage:(NSString *)message
{
    if ([message isEqualToString:@""]) {
        message = nil;
    }
    _message = message;
    self.messageLabel.text = message;
}

- (UILabel *)titleLabel {
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = [self titleColor];
        _titleLabel.font = [self titleFont];
    }
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if(!_messageLabel){
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        _messageLabel.numberOfLines = 0;
        _messageLabel.textColor = [self messageColor];
        _messageLabel.font = [self messageFont];
    }
    return _messageLabel;
}

- (UIImageView *)iconImageView {
    if(!_iconImageView){
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.image = [self iconViewImage];
    }
    return _iconImageView;
}

@end
