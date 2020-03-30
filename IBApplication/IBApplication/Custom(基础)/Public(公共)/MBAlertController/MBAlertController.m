//
//  MBAlertController.m
//  IBApplication
//
//  Created by Bowen on 2020/3/30.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBAlertController.h"

static NSUInteger alertControllerCount = 0;

@interface MBAlertButtonWrapView : UIView

@property(nonatomic, strong) MBButton *button;

@end

@implementation MBAlertButtonWrapView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.button = [[MBButton alloc] init];
        self.button.adjustsButtonWhenDisabled = NO;
        self.button.adjustsButtonWhenHighlighted = NO;
        [self addSubview:self.button];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.button.frame = self.bounds;
}

@end


#pragma mark - MBAlertAction

@protocol MBAlertActionDelegate <NSObject>

- (void)didClickAlertAction:(MBAlertAction *)alertAction;

@end

@interface MBAlertAction ()

@property(nonatomic, copy, readwrite) NSString *title;
@property(nonatomic, assign, readwrite) MBAlertActionStyle style;
@property(nonatomic, copy) void (^handler)(MBAlertController *aAlertController, MBAlertAction *action);
@property(nonatomic, weak) id<MBAlertActionDelegate> delegate;

@end

@implementation MBAlertAction

+ (nonnull instancetype)actionWithTitle:(nullable NSString *)title style:(MBAlertActionStyle)style handler:(void (^)(__kindof MBAlertController *, MBAlertAction *))handler {
    MBAlertAction *alertAction = [[MBAlertAction alloc] init];
    alertAction.title = title;
    alertAction.style = style;
    alertAction.handler = handler;
    return alertAction;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _button = [[MBButton alloc] init];
        self.button.adjustsButtonWhenDisabled = NO;
        self.button.adjustsButtonWhenHighlighted = NO;
        self.button.MB_automaticallyAdjustTouchHighlightedInScrollView = YES;
        [self.button addTarget:self action:@selector(handleAlertActionEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.button.enabled = enabled;
}

- (void)handleAlertActionEvent:(id)sender {
    // 需要先调delegate，里面会先恢复keywindow
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAlertAction:)]) {
        [self.delegate didClickAlertAction:self];
    }
}

@end

#pragma mark - MBAlertController

@interface MBAlertController () <MBAlertActionDelegate, MBModalPresentationContentViewControllerProtocol, MBModalPresentationViewControllerDelegate, MBTextFieldDelegate>

@property(nonatomic, assign, readwrite) MBAlertControllerStyle preferredStyle;
@property(nonatomic, strong, readwrite) MBModalPresentationViewController *modalPresentationViewController;

@property(nonatomic, strong) UIView *containerView;

@property(nonatomic, strong) UIControl *maskView;

@property(nonatomic, strong) UIView *scrollWrapView;
@property(nonatomic, strong) UIScrollView *headerScrollView;
@property(nonatomic, strong) UIScrollView *buttonScrollView;

@property(nonatomic, strong) CALayer *extendLayer;

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *messageLabel;
@property(nonatomic, strong) MBAlertAction *cancelAction;

@property(nonatomic, strong) NSMutableArray<MBAlertAction *> *alertActions;
@property(nonatomic, strong) NSMutableArray<MBAlertAction *> *destructiveActions;
@property(nonatomic, strong) NSMutableArray<UITextField *> *alertTextFields;

@property(nonatomic, assign) CGFloat keyboardHeight;

/// 调用 showWithAnimated 时置为 YES，在 show 动画结束时置为 NO
@property(nonatomic, assign) BOOL willShow;

/// 在 show 动画结束时置为 YES，在 hide 动画结束时置为 NO
@property(nonatomic, assign) BOOL showing;

// 保护 showing 的过程中调用 hide 无效
@property(nonatomic, assign) BOOL isNeedsHideAfterAlertShowed;
@property(nonatomic, assign) BOOL isAnimatedForHideAfterAlertShowed;

@end

@implementation MBAlertController {
    NSString            *_title;
    BOOL _needsUpdateAction;
    BOOL _needsUpdateTitle;
    BOOL _needsUpdateMessage;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    if (alertControllerAppearance) {
        self.alertContentMargin = [MBAlertController appearance].alertContentMargin;
        self.alertContentMaximumWidth = [MBAlertController appearance].alertContentMaximumWidth;
        self.alertSeparatorColor = [MBAlertController appearance].alertSeparatorColor;
        self.alertContentCornerRadius = [MBAlertController appearance].alertContentCornerRadius;
        self.alertTitleAttributes = [MBAlertController appearance].alertTitleAttributes;
        self.alertMessageAttributes = [MBAlertController appearance].alertMessageAttributes;
        self.alertButtonAttributes = [MBAlertController appearance].alertButtonAttributes;
        self.alertButtonDisabledAttributes = [MBAlertController appearance].alertButtonDisabledAttributes;
        self.alertCancelButtonAttributes = [MBAlertController appearance].alertCancelButtonAttributes;
        self.alertDestructiveButtonAttributes = [MBAlertController appearance].alertDestructiveButtonAttributes;
        self.alertButtonHeight = [MBAlertController appearance].alertButtonHeight;
        self.alertHeaderBackgroundColor = [MBAlertController appearance].alertHeaderBackgroundColor;
        self.alertButtonBackgroundColor = [MBAlertController appearance].alertButtonBackgroundColor;
        self.alertButtonHighlightBackgroundColor = [MBAlertController appearance].alertButtonHighlightBackgroundColor;
        self.alertHeaderInsets = [MBAlertController appearance].alertHeaderInsets;
        self.alertTitleMessageSpacing = [MBAlertController appearance].alertTitleMessageSpacing;
        self.alertTextFieldFont = [MBAlertController appearance].alertTextFieldFont;
        self.alertTextFieldTextColor = [MBAlertController appearance].alertTextFieldTextColor;
        self.alertTextFieldBorderColor = [MBAlertController appearance].alertTextFieldBorderColor;
        
        self.sheetContentMargin = [MBAlertController appearance].sheetContentMargin;
        self.sheetContentMaximumWidth = [MBAlertController appearance].sheetContentMaximumWidth;
        self.sheetSeparatorColor = [MBAlertController appearance].sheetSeparatorColor;
        self.sheetTitleAttributes = [MBAlertController appearance].sheetTitleAttributes;
        self.sheetMessageAttributes = [MBAlertController appearance].sheetMessageAttributes;
        self.sheetButtonAttributes = [MBAlertController appearance].sheetButtonAttributes;
        self.sheetButtonDisabledAttributes = [MBAlertController appearance].sheetButtonDisabledAttributes;
        self.sheetCancelButtonAttributes = [MBAlertController appearance].sheetCancelButtonAttributes;
        self.sheetDestructiveButtonAttributes = [MBAlertController appearance].sheetDestructiveButtonAttributes;
        self.sheetCancelButtonMarginTop = [MBAlertController appearance].sheetCancelButtonMarginTop;
        self.sheetContentCornerRadius = [MBAlertController appearance].sheetContentCornerRadius;
        self.sheetButtonHeight = [MBAlertController appearance].sheetButtonHeight;
        self.sheetHeaderBackgroundColor = [MBAlertController appearance].sheetHeaderBackgroundColor;
        self.sheetButtonBackgroundColor = [MBAlertController appearance].sheetButtonBackgroundColor;
        self.sheetButtonHighlightBackgroundColor = [MBAlertController appearance].sheetButtonHighlightBackgroundColor;
        self.sheetHeaderInsets = [MBAlertController appearance].sheetHeaderInsets;
        self.sheetTitleMessageSpacing = [MBAlertController appearance].sheetTitleMessageSpacing;
        self.isExtendBottomLayout = [MBAlertController appearance].isExtendBottomLayout;
    }
    
    self.shouldManageTextFieldsReturnEventAutomatically = YES;
    self.dismissKeyboardAutomatically = YES;
}

- (void)setAlertButtonAttributes:(NSDictionary<NSString *,id> *)alertButtonAttributes {
    _alertButtonAttributes = alertButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonAttributes:(NSDictionary<NSString *,id> *)sheetButtonAttributes {
    _sheetButtonAttributes = sheetButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertButtonDisabledAttributes:(NSDictionary<NSString *,id> *)alertButtonDisabledAttributes {
    _alertButtonDisabledAttributes = alertButtonDisabledAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonDisabledAttributes:(NSDictionary<NSString *,id> *)sheetButtonDisabledAttributes {
    _sheetButtonDisabledAttributes = sheetButtonDisabledAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertCancelButtonAttributes:(NSDictionary<NSString *,id> *)alertCancelButtonAttributes {
    _alertCancelButtonAttributes = alertCancelButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetCancelButtonAttributes:(NSDictionary<NSString *,id> *)sheetCancelButtonAttributes {
    _sheetCancelButtonAttributes = sheetCancelButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertDestructiveButtonAttributes:(NSDictionary<NSString *,id> *)alertDestructiveButtonAttributes {
    _alertDestructiveButtonAttributes = alertDestructiveButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetDestructiveButtonAttributes:(NSDictionary<NSString *,id> *)sheetDestructiveButtonAttributes {
    _sheetDestructiveButtonAttributes = sheetDestructiveButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertButtonBackgroundColor:(UIColor *)alertButtonBackgroundColor {
    _alertButtonBackgroundColor = alertButtonBackgroundColor;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonBackgroundColor:(UIColor *)sheetButtonBackgroundColor {
    _sheetButtonBackgroundColor = sheetButtonBackgroundColor;
    [self updateExtendLayerAppearance];
    _needsUpdateAction = YES;
}

- (void)setAlertButtonHighlightBackgroundColor:(UIColor *)alertButtonHighlightBackgroundColor {
    _alertButtonHighlightBackgroundColor = alertButtonHighlightBackgroundColor;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonHighlightBackgroundColor:(UIColor *)sheetButtonHighlightBackgroundColor {
    _sheetButtonHighlightBackgroundColor = sheetButtonHighlightBackgroundColor;
    _needsUpdateAction = YES;
}

- (void)setAlertTitleAttributes:(NSDictionary<NSString *,id> *)alertTitleAttributes {
    _alertTitleAttributes = alertTitleAttributes;
    _needsUpdateTitle = YES;
}

- (void)setAlertMessageAttributes:(NSDictionary<NSString *,id> *)alertMessageAttributes {
    _alertMessageAttributes = alertMessageAttributes;
    _needsUpdateMessage = YES;
}

- (void)setSheetTitleAttributes:(NSDictionary<NSString *,id> *)sheetTitleAttributes {
    _sheetTitleAttributes = sheetTitleAttributes;
    _needsUpdateTitle = YES;
}

- (void)setSheetMessageAttributes:(NSDictionary<NSString *,id> *)sheetMessageAttributes {
    _sheetMessageAttributes = sheetMessageAttributes;
    _needsUpdateMessage = YES;
}

- (void)setAlertHeaderBackgroundColor:(UIColor *)alertHeaderBackgroundColor {
    _alertHeaderBackgroundColor = alertHeaderBackgroundColor;
    [self updateHeaderBackgrondColor];
}

- (void)setSheetHeaderBackgroundColor:(UIColor *)sheetHeaderBackgroundColor {
    _sheetHeaderBackgroundColor = sheetHeaderBackgroundColor;
    [self updateHeaderBackgrondColor];
}

- (void)updateHeaderBackgrondColor {
    if (self.preferredStyle == MBAlertControllerStyleActionSheet) {
        if (self.headerScrollView) { self.headerScrollView.backgroundColor = self.sheetHeaderBackgroundColor; }
    } else if (self.preferredStyle == MBAlertControllerStyleAlert) {
        if (self.headerScrollView) { self.headerScrollView.backgroundColor = self.alertHeaderBackgroundColor; }
    }
}

- (void)setAlertSeparatorColor:(UIColor *)alertSeparatorColor {
    _alertSeparatorColor = alertSeparatorColor;
    [self updateSeparatorColor];
}

- (void)setSheetSeparatorColor:(UIColor *)sheetSeparatorColor {
    _sheetSeparatorColor = sheetSeparatorColor;
    [self updateSeparatorColor];
}

- (void)updateSeparatorColor {
    UIColor *separatorColor = self.preferredStyle == MBAlertControllerStyleAlert ? self.alertSeparatorColor : self.sheetSeparatorColor;
    [self.alertActions enumerateObjectsUsingBlock:^(MBAlertAction * _Nonnull alertAction, NSUInteger idx, BOOL * _Nonnull stop) {
        alertAction.button.MB_borderColor = separatorColor;
    }];
}

- (void)setAlertContentCornerRadius:(CGFloat)alertContentCornerRadius {
    _alertContentCornerRadius = alertContentCornerRadius;
    [self updateCornerRadius];
}

- (void)setSheetContentCornerRadius:(CGFloat)sheetContentCornerRadius {
    _sheetContentCornerRadius = sheetContentCornerRadius;
    [self updateCornerRadius];
}

- (void)setIsExtendBottomLayout:(BOOL)isExtendBottomLayout {
    _isExtendBottomLayout = isExtendBottomLayout;
    if (isExtendBottomLayout) {
        self.extendLayer.hidden = NO;
        [self updateExtendLayerAppearance];
    } else {
        self.extendLayer.hidden = YES;
    }
}

- (void)updateExtendLayerAppearance {
    if (self.extendLayer) {
        self.extendLayer.backgroundColor = self.sheetButtonBackgroundColor.CGColor;
    }
}

- (void)updateCornerRadius {
    if (self.preferredStyle == MBAlertControllerStyleAlert) {
        if (self.containerView) { self.containerView.layer.cornerRadius = self.alertContentCornerRadius; self.containerView.clipsToBounds = YES; }
        if (self.cancelButtonVisualEffectView) { self.cancelButtonVisualEffectView.layer.cornerRadius = self.alertContentCornerRadius; self.cancelButtonVisualEffectView.clipsToBounds = NO;}
        if (self.scrollWrapView) { self.scrollWrapView.layer.cornerRadius = 0; self.scrollWrapView.clipsToBounds = NO; }
    } else {
        if (self.containerView) { self.containerView.layer.cornerRadius = 0; self.containerView.clipsToBounds = NO; }
        if (self.cancelButtonVisualEffectView) { self.cancelButtonVisualEffectView.layer.cornerRadius = self.sheetContentCornerRadius; self.cancelButtonVisualEffectView.clipsToBounds = YES; }
        if (self.scrollWrapView) { self.scrollWrapView.layer.cornerRadius = self.sheetContentCornerRadius; self.scrollWrapView.clipsToBounds = YES; }
    }
}

- (void)setAlertTextFieldFont:(UIFont *)alertTextFieldFont {
    _alertTextFieldFont = alertTextFieldFont;
    [self.textFields enumerateObjectsUsingBlock:^(MBTextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.font = alertTextFieldFont;
    }];
}

- (void)setAlertTextFieldBorderColor:(UIColor *)alertTextFieldBorderColor {
    _alertTextFieldBorderColor = alertTextFieldBorderColor;
    [self.textFields enumerateObjectsUsingBlock:^(MBTextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.layer.borderColor = alertTextFieldBorderColor.CGColor;
    }];
}

- (void)setAlertTextFieldTextColor:(UIColor *)alertTextFieldTextColor {
    _alertTextFieldTextColor = alertTextFieldTextColor;
    [self.textFields enumerateObjectsUsingBlock:^(MBTextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.textColor = alertTextFieldTextColor;
    }];
}

- (void)setMainVisualEffectView:(UIView *)mainVisualEffectView {
    if (!mainVisualEffectView) {
        // 不允许为空
        mainVisualEffectView = [[UIView alloc] init];
    }
    BOOL isValueChanged = _mainVisualEffectView != mainVisualEffectView;
    if (isValueChanged) {
        if ([_mainVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
            [((UIVisualEffectView *)_mainVisualEffectView).contentView MB_removeAllSubviews];
        } else {
            [_mainVisualEffectView MB_removeAllSubviews];
        }
        [_mainVisualEffectView removeFromSuperview];
        _mainVisualEffectView = nil;
    }
    _mainVisualEffectView = mainVisualEffectView;
    if (isValueChanged) {
        [self.scrollWrapView insertSubview:_mainVisualEffectView atIndex:0];
        [self updateCornerRadius];
    }
}

- (void)setCancelButtonVisualEffectView:(UIView *)cancelButtonVisualEffectView {
    if (!cancelButtonVisualEffectView) {
        // 不允许为空
        cancelButtonVisualEffectView = [[UIView alloc] init];
    }
    BOOL isValueChanged = _cancelButtonVisualEffectView != cancelButtonVisualEffectView;
    if (isValueChanged) {
        if ([_cancelButtonVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
            [((UIVisualEffectView *)_cancelButtonVisualEffectView).contentView MB_removeAllSubviews];
        } else {
            [_cancelButtonVisualEffectView MB_removeAllSubviews];
        }
        [_cancelButtonVisualEffectView removeFromSuperview];
        _cancelButtonVisualEffectView = nil;
    }
    _cancelButtonVisualEffectView = cancelButtonVisualEffectView;
    if (isValueChanged) {
        [self.containerView addSubview:_cancelButtonVisualEffectView];
        if (self.preferredStyle == MBAlertControllerStyleActionSheet && self.cancelAction && !self.cancelAction.button.superview) {
            if ([_cancelButtonVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
                UIVisualEffectView *effectView = (UIVisualEffectView *)_cancelButtonVisualEffectView;
                [effectView.contentView addSubview:self.cancelAction.button];
            } else {
                [_cancelButtonVisualEffectView addSubview:self.cancelAction.button];
            }
        }
        
        [self updateCornerRadius];
    }
}

+ (nonnull instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(MBAlertControllerStyle)preferredStyle {
    MBAlertController *alertController = [[self alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
    if (alertController) {
        return alertController;
    }
    return nil;
}

- (nonnull instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(MBAlertControllerStyle)preferredStyle {
    self = [self init];
    if (self) {
        
        self.preferredStyle = preferredStyle;
    
        self.shouldRespondMaskViewTouch = preferredStyle == MBAlertControllerStyleActionSheet;
        
        self.alertActions = [[NSMutableArray alloc] init];
        self.alertTextFields = [[NSMutableArray alloc] init];
        self.destructiveActions = [[NSMutableArray alloc] init];
        
        self.containerView = [[UIView alloc] init];
        
        self.maskView = [[UIControl alloc] init];
        self.maskView.alpha = 0;
        self.maskView.backgroundColor = UIColorMask;
        [self.maskView addTarget:self action:@selector(handleMaskViewEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        self.scrollWrapView = [[UIView alloc] init];
        self.mainVisualEffectView = [[UIView alloc] init];
        self.cancelButtonVisualEffectView = [[UIView alloc] init];
        self.headerScrollView = [[UIScrollView alloc] init];
        self.headerScrollView.scrollsToTop = NO;
        self.buttonScrollView = [[UIScrollView alloc] init];
        self.buttonScrollView.scrollsToTop = NO;
        if (@available(iOS 11, *)) {
            self.headerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.buttonScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        self.extendLayer = [CALayer layer];
        self.extendLayer.hidden = !self.isExtendBottomLayout;
        [self.extendLayer MB_removeDefaultAnimations];
        
        self.title = title;
        self.message = message;
        
        [self updateHeaderBackgrondColor];
        [self updateExtendLayerAppearance];
        
    }
    return self;
}

- (MBAlertControllerStyle)preferredStyle {
    return PreferredValueForDeviceIncludingiPad(1, 0, 0, 0, 0) > 0 ? MBAlertControllerStyleAlert : _preferredStyle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.scrollWrapView];
    [self.scrollWrapView addSubview:self.headerScrollView];
    [self.scrollWrapView addSubview:self.buttonScrollView];
    [self.containerView.layer addSublayer:self.extendLayer];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    BOOL hasTitle = (self.titleLabel.text.length > 0 && !self.titleLabel.hidden);
    BOOL hasMessage = (self.messageLabel.text.length > 0 && !self.messageLabel.hidden);
    BOOL hasTextField = self.alertTextFields.count > 0;
    BOOL hasCustomView = !!_customView;
    CGFloat contentOriginY = 0;
    
    self.maskView.frame = self.view.bounds;
    
    if (self.preferredStyle == MBAlertControllerStyleAlert) {
        
        CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
        CGFloat contentPaddingRight = self.alertHeaderInsets.right;
        
        CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField || hasCustomView) ? self.alertHeaderInsets.top : 0;
        CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField || hasCustomView) ? self.alertHeaderInsets.bottom : 0;
        self.containerView.MB_width = fmin(self.alertContentMaximumWidth, CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(self.alertContentMargin));
        self.scrollWrapView.MB_width = CGRectGetWidth(self.containerView.bounds);
        self.headerScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), 0);
        contentOriginY = contentPaddingTop;
        // 标题和副标题布局
        if (hasTitle) {
            self.titleLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, MBViewSelfSizingHeight));
            contentOriginY = CGRectGetMaxY(self.titleLabel.frame) + (hasMessage ? self.alertTitleMessageSpacing : contentPaddingBottom);
        }
        if (hasMessage) {
            self.messageLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, MBViewSelfSizingHeight));
            contentOriginY = CGRectGetMaxY(self.messageLabel.frame) + contentPaddingBottom;
        }
        // 输入框布局
        if (hasTextField) {
            for (int i = 0; i < self.alertTextFields.count; i++) {
                UITextField *textField = self.alertTextFields[i];
                textField.frame = CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, 25);
                contentOriginY = CGRectGetMaxY(textField.frame) - 1;
            }
            contentOriginY += 16;
        }
        // 自定义view的布局 - 自动居中
        if (hasCustomView) {
            CGSize customViewSize = [_customView sizeThatFits:CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), CGFLOAT_MAX)];
            _customView.frame = CGRectFlatted(CGRectMake((CGRectGetWidth(self.headerScrollView.bounds) - customViewSize.width) / 2, contentOriginY, customViewSize.width, customViewSize.height));
            contentOriginY = CGRectGetMaxY(_customView.frame) + contentPaddingBottom;
        }
        // 内容scrollView的布局
        self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentOriginY);
        self.headerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), contentOriginY);
        contentOriginY = CGRectGetMaxY(self.headerScrollView.frame);
        // 按钮布局
        self.buttonScrollView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = 0;
        NSArray<MBAlertAction *> *newOrderActions = [self orderedAlertActions:self.alertActions];
        if (newOrderActions.count > 0) {
            BOOL verticalLayout = YES;
            if (self.alertActions.count == 2) {
                CGFloat halfWidth = CGRectGetWidth(self.buttonScrollView.bounds) / 2;
                MBAlertAction *action1 = newOrderActions[0];
                MBAlertAction *action2 = newOrderActions[1];
                CGSize actionSize1 = [action1.button sizeThatFits:CGSizeMax];
                CGSize actionSize2 = [action2.button sizeThatFits:CGSizeMax];
                if (actionSize1.width < halfWidth && actionSize2.width < halfWidth) {
                    verticalLayout = NO;
                }
            }
            if (!verticalLayout) {
                // 对齐系统，先 add 的在右边，后 add 的在左边
                MBAlertAction *leftAction = newOrderActions[1];
                leftAction.button.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.buttonScrollView.bounds) / 2, self.alertButtonHeight);
                leftAction.button.MB_borderPosition = MBViewBorderPositionTop|MBViewBorderPositionRight;
                MBAlertAction *rightAction = newOrderActions[0];
                rightAction.button.frame = CGRectMake(CGRectGetMaxX(leftAction.button.frame), contentOriginY, CGRectGetWidth(self.buttonScrollView.bounds) / 2, self.alertButtonHeight);
                rightAction.button.MB_borderPosition = MBViewBorderPositionTop;
                contentOriginY = CGRectGetMaxY(leftAction.button.frame);
            } else {
                for (int i = 0; i < newOrderActions.count; i++) {
                    MBAlertAction *action = newOrderActions[i];
                    action.button.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), self.alertButtonHeight);
                    action.button.MB_borderPosition = MBViewBorderPositionTop;
                    contentOriginY = CGRectGetMaxY(action.button.frame);
                }
            }
        }
        // 按钮scrollView的布局
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, contentOriginY);
        self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.buttonScrollView.bounds), contentOriginY);
        // 容器最后布局
        CGFloat contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds);
        CGFloat screenSpaceHeight = CGRectGetHeight(self.view.bounds);
        if (contentHeight > screenSpaceHeight - 20) {
            screenSpaceHeight -= 20;
            CGFloat contentH = fmin(CGRectGetHeight(self.headerScrollView.bounds), screenSpaceHeight / 2);
            CGFloat buttonH = fmin(CGRectGetHeight(self.buttonScrollView.bounds), screenSpaceHeight / 2);
            if (contentH >= screenSpaceHeight / 2 && buttonH >= screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight / 2);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight / 2);
            } else if (contentH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight - contentH);
            } else if (buttonH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight - buttonH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, buttonH);
            }
            contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds);
            screenSpaceHeight += 20;
        }
        self.scrollWrapView.frame =  CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), contentHeight);
        self.mainVisualEffectView.frame = self.scrollWrapView.bounds;
        
        CGRect containerRect = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.containerView.bounds)) / 2, (screenSpaceHeight - contentHeight - self.keyboardHeight) / 2, CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.scrollWrapView.bounds));
        self.containerView.frame = CGRectFlatted(CGRectApplyAffineTransform(containerRect, self.containerView.transform));
    }
    
    else if (self.preferredStyle == MBAlertControllerStyleActionSheet) {
        
        CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
        CGFloat contentPaddingRight = self.alertHeaderInsets.right;
        
        CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField) ? self.sheetHeaderInsets.top : 0;
        CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField) ? self.sheetHeaderInsets.bottom : 0;
        self.containerView.MB_width = fmin(self.sheetContentMaximumWidth, CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(self.sheetContentMargin));
        self.scrollWrapView.MB_width = CGRectGetWidth(self.containerView.bounds);
        self.headerScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = contentPaddingTop;
        // 标题和副标题布局
        if (hasTitle) {
            self.titleLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, MBViewSelfSizingHeight));
            contentOriginY = CGRectGetMaxY(self.titleLabel.frame) + (hasMessage ? self.sheetTitleMessageSpacing : contentPaddingBottom);
        }
        if (hasMessage) {
            self.messageLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, MBViewSelfSizingHeight));
            contentOriginY = CGRectGetMaxY(self.messageLabel.frame) + contentPaddingBottom;
        }
        // 自定义view的布局 - 自动居中
        if (hasCustomView) {
            CGSize customViewSize = [_customView sizeThatFits:CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), CGFLOAT_MAX)];
            _customView.frame = CGRectFlatted(CGRectMake((CGRectGetWidth(self.headerScrollView.bounds) - customViewSize.width) / 2, contentOriginY, customViewSize.width, customViewSize.height));
            contentOriginY = CGRectGetMaxY(_customView.frame) + contentPaddingBottom;
        }
        // 内容scrollView布局
        self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentOriginY);
        self.headerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), contentOriginY);
        contentOriginY = CGRectGetMaxY(self.headerScrollView.frame);
        // 按钮的布局
        self.buttonScrollView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = 0;
        NSArray<MBAlertAction *> *newOrderActions = [self orderedAlertActions:self.alertActions];
        if (self.alertActions.count > 0) {
            contentOriginY = (hasTitle || hasMessage || hasCustomView) ? contentOriginY : contentOriginY;
            for (int i = 0; i < newOrderActions.count; i++) {
                MBAlertAction *action = newOrderActions[i];
                if (action.style == MBAlertActionStyleCancel && i == newOrderActions.count - 1) {
                    continue;
                } else {
                    action.button.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.buttonScrollView.bounds), self.sheetButtonHeight);
                    action.button.MB_borderPosition = MBViewBorderPositionTop;
                    contentOriginY = CGRectGetMaxY(action.button.frame);
                }
            }
        }
        // 按钮scrollView布局
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, contentOriginY);
        self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.buttonScrollView.bounds), contentOriginY);
        // 容器最终布局
        self.scrollWrapView.frame =  CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), CGRectGetMaxY(self.buttonScrollView.frame));
        self.mainVisualEffectView.frame = self.scrollWrapView.bounds;
        contentOriginY = CGRectGetMaxY(self.scrollWrapView.frame) + self.sheetCancelButtonMarginTop;
        if (self.cancelAction) {
            self.cancelButtonVisualEffectView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), self.sheetButtonHeight);
            self.cancelAction.button.frame = self.cancelButtonVisualEffectView.bounds;
            contentOriginY = CGRectGetMaxY(self.cancelButtonVisualEffectView.frame);
        }
        // 把上下的margin都加上用于跟整个屏幕的高度做比较
        CGFloat contentHeight = contentOriginY + UIEdgeInsetsGetVerticalValue(self.sheetContentMargin);
        CGFloat screenSpaceHeight = CGRectGetHeight(self.view.bounds);
        if (contentHeight > screenSpaceHeight) {
            CGFloat cancelButtonAreaHeight = (self.cancelAction ? (CGRectGetHeight(self.cancelAction.button.bounds) + self.sheetCancelButtonMarginTop) : 0);
            screenSpaceHeight = screenSpaceHeight - cancelButtonAreaHeight - UIEdgeInsetsGetVerticalValue(self.sheetContentMargin);
            CGFloat contentH = MIN(CGRectGetHeight(self.headerScrollView.bounds), screenSpaceHeight / 2);
            CGFloat buttonH = MIN(CGRectGetHeight(self.buttonScrollView.bounds), screenSpaceHeight / 2);
            if (contentH >= screenSpaceHeight / 2 && buttonH >= screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight / 2);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight / 2);
            } else if (contentH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight - contentH);
            } else if (buttonH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight - buttonH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, buttonH);
            }
            self.scrollWrapView.frame =  CGRectSetHeight(self.scrollWrapView.frame, CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds));
            if (self.cancelAction) {
                self.cancelButtonVisualEffectView.frame = CGRectSetY(self.cancelButtonVisualEffectView.frame, CGRectGetMaxY(self.scrollWrapView.frame) + self.sheetCancelButtonMarginTop);
            }
            contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds) + cancelButtonAreaHeight + self.sheetContentMargin.bottom;
            screenSpaceHeight += (cancelButtonAreaHeight + UIEdgeInsetsGetVerticalValue(self.sheetContentMargin));
        } else {
            // 如果小于屏幕高度，则把顶部的top减掉
            contentHeight -= self.sheetContentMargin.top;
        }
        
        CGRect containerRect = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.containerView.bounds)) / 2, screenSpaceHeight - contentHeight - SafeAreaInsetsConstantForDeviceWithNotch.bottom, CGRectGetWidth(self.containerView.bounds), contentHeight + (self.isExtendBottomLayout ? SafeAreaInsetsConstantForDeviceWithNotch.bottom : 0));
        self.containerView.frame = CGRectFlatted(CGRectApplyAffineTransform(containerRect, self.containerView.transform));
        
        self.extendLayer.frame = CGRectFlatMake(0, CGRectGetHeight(self.containerView.bounds) - SafeAreaInsetsConstantForDeviceWithNotch.bottom - 1, CGRectGetWidth(self.containerView.bounds), SafeAreaInsetsConstantForDeviceWithNotch.bottom + 1);
    }
}

- (NSArray<MBAlertAction *> *)orderedAlertActions:(NSArray<MBAlertAction *> *)actions {
    NSMutableArray<MBAlertAction *> *newActions = [[NSMutableArray alloc] init];
    // 按照用户addAction的先后顺序来排序
    if (self.orderActionsByAddedOrdered) {
        [newActions addObjectsFromArray:self.alertActions];
        // 取消按钮不参与排序，所以先移除，在最后再重新添加
        if (self.cancelAction) {
            [newActions removeObject:self.cancelAction];
        }
    } else {
        for (MBAlertAction *action in self.alertActions) {
            if (action.style != MBAlertActionStyleCancel && action.style != MBAlertActionStyleDestructive) {
                [newActions addObject:action];
            }
        }
        for (MBAlertAction *action in self.destructiveActions) {
            [newActions addObject:action];
        }
    }
    if (self.cancelAction) {
        [newActions addObject:self.cancelAction];
    }
    return newActions;
}

- (void)initModalPresentationController {
    _modalPresentationViewController = [[MBModalPresentationViewController alloc] init];
    self.modalPresentationViewController.delegate = self;
    self.modalPresentationViewController.maximumContentViewWidth = CGFLOAT_MAX;
    self.modalPresentationViewController.contentViewMargins = UIEdgeInsetsZero;
    self.modalPresentationViewController.dimmingView = nil;
    self.modalPresentationViewController.contentViewController = self;
    [self customModalPresentationControllerAnimation];
}

- (void)customModalPresentationControllerAnimation {
    
    __weak __typeof(self)weakSelf = self;
    
    self.modalPresentationViewController.layoutBlock = ^(CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewDefaultFrame) {
        weakSelf.view.frame = CGRectMake(0, 0, CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
        weakSelf.keyboardHeight = keyboardHeight;
        [weakSelf.view setNeedsLayout];
    };
    
    self.modalPresentationViewController.showingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewFrame, void(^completion)(BOOL finished)) {
        if (self.preferredStyle == MBAlertControllerStyleAlert) {
            weakSelf.containerView.alpha = 0;
            weakSelf.containerView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0);
            [UIView animateWithDuration:0.25f delay:0 options:MBViewAnimationOptionsCurveOut animations:^{
                weakSelf.maskView.alpha = 1;
                weakSelf.containerView.alpha = 1;
                weakSelf.containerView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        } else if (self.preferredStyle == MBAlertControllerStyleActionSheet) {
            weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.view.bounds) - CGRectGetMinY(weakSelf.containerView.frame), 0);
            [UIView animateWithDuration:0.25f delay:0 options:MBViewAnimationOptionsCurveOut animations:^{
                weakSelf.maskView.alpha = 1;
                weakSelf.containerView.layer.transform = CATransform3DIdentity;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        }
    };
    
    self.modalPresentationViewController.hidingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, void(^completion)(BOOL finished)) {
        if (self.preferredStyle == MBAlertControllerStyleAlert) {
            [UIView animateWithDuration:0.25f delay:0 options:MBViewAnimationOptionsCurveOut animations:^{
                weakSelf.maskView.alpha = 0;
                weakSelf.containerView.alpha = 0;
            } completion:^(BOOL finished) {
                weakSelf.containerView.alpha = 1;
                if (completion) {
                    completion(finished);
                }
            }];
        } else if (self.preferredStyle == MBAlertControllerStyleActionSheet) {
            [UIView animateWithDuration:0.25f delay:0 options:MBViewAnimationOptionsCurveOut animations:^{
                weakSelf.maskView.alpha = 0;
                weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.view.bounds) - CGRectGetMinY(weakSelf.containerView.frame), 0);
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        }
    };
}

- (void)showWithAnimated:(BOOL)animated {
    if (self.willShow || self.showing) {
        return;
    }
    self.willShow = YES;
    
    if (self.alertTextFields.count > 0) {
        [self.alertTextFields.firstObject becomeFirstResponder];
    } else {
        // iOS 10 及以上的版本在显示 window 时都会自动降下当前 App 的键盘，所以只有 iOS 9 及以下才需要手动处理
        if (@available(iOS 10.0, *)) {
        } else {
            if (self.dismissKeyboardAutomatically && [MBKeyboardManager isKeyboardVisible]) {
                [UIApplication.sharedApplication sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
            }
        }
    }
    if (_needsUpdateAction) {
        [self updateAction];
    }
    if (_needsUpdateTitle) {
        [self updateTitleLabel];
    }
    if (_needsUpdateMessage) {
        [self updateMessageLabel];
    }
    
    [self initModalPresentationController];
    
    if ([self.delegate respondsToSelector:@selector(willShowAlertController:)]) {
        [self.delegate willShowAlertController:self];
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [self.modalPresentationViewController showWithAnimated:animated completion:^(BOOL finished) {
        weakSelf.maskView.alpha = 1;
        weakSelf.willShow = NO;
        weakSelf.showing = YES;
        if (weakSelf.isNeedsHideAfterAlertShowed) {
            [weakSelf hideWithAnimated:weakSelf.isAnimatedForHideAfterAlertShowed];
            weakSelf.isNeedsHideAfterAlertShowed = NO;
            weakSelf.isAnimatedForHideAfterAlertShowed = NO;
        }
        if ([weakSelf.delegate respondsToSelector:@selector(didShowAlertController:)]) {
            [weakSelf.delegate didShowAlertController:weakSelf];
        }
    }];
    
    // 增加alertController计数
    alertControllerCount++;
}

- (void)hideWithAnimated:(BOOL)animated {
    [self hideWithAnimated:animated completion:NULL];
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if ([self.delegate respondsToSelector:@selector(shouldHideAlertController:)] && ![self.delegate shouldHideAlertController:self]) {
        return;
    }
    
    if (!self.showing) {
        if (self.willShow) {
            self.isNeedsHideAfterAlertShowed = YES;
            self.isAnimatedForHideAfterAlertShowed = animated;
        }
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(willHideAlertController:)]) {
        [self.delegate willHideAlertController:self];
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [self.modalPresentationViewController hideWithAnimated:animated completion:^(BOOL finished) {
        weakSelf.modalPresentationViewController = nil;
        weakSelf.willShow = NO;
        weakSelf.showing = NO;
        weakSelf.maskView.alpha = 0;
        if (self.preferredStyle == MBAlertControllerStyleAlert) {
            weakSelf.containerView.alpha = 0;
        } else {
            weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.view.bounds) - CGRectGetMinY(weakSelf.containerView.frame), 0);
        }
        if ([weakSelf.delegate respondsToSelector:@selector(didHideAlertController:)]) {
            [weakSelf.delegate didHideAlertController:weakSelf];
        }
        if (completion) completion();
    }];
    
    // 减少alertController计数
    alertControllerCount--;
}

- (void)addAction:(nonnull MBAlertAction *)action {
    if (action.style == MBAlertActionStyleCancel && self.cancelAction) {
        [NSException raise:@"MBAlertController使用错误" format:@"同一个alertController不可以同时添加两个cancel按钮"];
    }
    if (action.style == MBAlertActionStyleCancel) {
        self.cancelAction = action;
    }
    if (action.style == MBAlertActionStyleDestructive) {
        [self.destructiveActions addObject:action];
    }
    // 只有ActionSheet的取消按钮不参与滚动
    if (self.preferredStyle == MBAlertControllerStyleActionSheet && action.style == MBAlertActionStyleCancel) {
        if (!self.cancelButtonVisualEffectView.superview) {
            [self.containerView addSubview:self.cancelButtonVisualEffectView];
        }
        if ([self.cancelButtonVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
            [((UIVisualEffectView *)self.cancelButtonVisualEffectView).contentView addSubview:action.button];
        } else {
            [self.cancelButtonVisualEffectView addSubview:action.button];
        }
    } else {
        [self.buttonScrollView addSubview:action.button];
    }
    action.delegate = self;
    [self.alertActions addObject:action];
}

- (void)addCancelAction {
    MBAlertAction *action = [MBAlertAction actionWithTitle:@"取消" style:MBAlertActionStyleCancel handler:nil];
    [self addAction:action];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(MBTextField *textField))configurationHandler {
    if (_customView) {
        [NSException raise:@"MBAlertController使用错误" format:@"UITextField和CustomView不能共存"];
    }
    if (self.preferredStyle == MBAlertControllerStyleActionSheet) {
        [NSException raise:@"MBAlertController使用错误" format:@"Sheet类型不运行添加UITextField"];
    }
    MBTextField *textField = [[MBTextField alloc] init];
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = UIColorWhite;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.font = self.alertTextFieldFont;
    textField.textColor = self.alertTextFieldTextColor;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.layer.borderColor = self.alertTextFieldBorderColor.CGColor;
    textField.layer.borderWidth = PixelOne;
    [self.headerScrollView addSubview:textField];
    [self.alertTextFields addObject:textField];
    if (configurationHandler) {
        configurationHandler(textField);
    }
}

- (void)addCustomView:(UIView *)view {
    if (view && self.alertTextFields.count > 0) {
        [NSException raise:@"MBAlertController使用错误" format:@"UITextField 和 customView 不能共存"];
    }
    if (_customView && _customView != view) {
        [_customView removeFromSuperview];
    }
    _customView = view;
    if (_customView) {
        [self.headerScrollView addSubview:_customView];
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.numberOfLines = 0;
        [self.headerScrollView addSubview:self.titleLabel];
    }
    if (!_title || [_title isEqualToString:@""]) {
        self.titleLabel.hidden = YES;
    } else {
        self.titleLabel.hidden = NO;
        [self updateTitleLabel];
    }
}

- (NSString *)title {
    return _title;
}

- (void)updateTitleLabel {
    if (self.titleLabel && !self.titleLabel.hidden) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.title attributes:self.preferredStyle == MBAlertControllerStyleAlert ? self.alertTitleAttributes : self.sheetTitleAttributes];
        self.titleLabel.attributedText = attributeString;
    }
}

- (void)setMessage:(NSString *)message {
    _message = message;
    if (!self.messageLabel) {
        self.messageLabel = [[UILabel alloc] init];
        self.messageLabel.numberOfLines = 0;
        [self.headerScrollView addSubview:self.messageLabel];
    }
    if (!_message || [_message isEqualToString:@""]) {
        self.messageLabel.hidden = YES;
    } else {
        self.messageLabel.hidden = NO;
        [self updateMessageLabel];
    }
}

- (void)updateMessageLabel {
    if (self.messageLabel && !self.messageLabel.hidden) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.message attributes:self.preferredStyle == MBAlertControllerStyleAlert ? self.alertMessageAttributes : self.sheetMessageAttributes];
        self.messageLabel.attributedText = attributeString;
    }
}

- (NSArray<MBAlertAction *> *)actions {
    return [self.alertActions copy];
}

- (void)updateAction {
    
    for (MBAlertAction *alertAction in self.alertActions) {
        
        UIColor *backgroundColor = self.preferredStyle == MBAlertControllerStyleAlert ? self.alertButtonBackgroundColor : self.sheetButtonBackgroundColor;
        UIColor *highlightBackgroundColor = self.preferredStyle == MBAlertControllerStyleAlert ? self.alertButtonHighlightBackgroundColor : self.sheetButtonHighlightBackgroundColor;
        UIColor *borderColor = self.preferredStyle == MBAlertControllerStyleAlert ? self.alertSeparatorColor : self.sheetSeparatorColor;
        
        alertAction.button.clipsToBounds = alertAction.style == MBAlertActionStyleCancel;
        alertAction.button.backgroundColor = backgroundColor;
        alertAction.button.highlightedBackgroundColor = highlightBackgroundColor;
        alertAction.button.MB_borderColor = borderColor;
        
        NSAttributedString *attributeString = nil;
        if (alertAction.style == MBAlertActionStyleCancel) {
            
            NSDictionary *attributes = (self.preferredStyle == MBAlertControllerStyleAlert) ? self.alertCancelButtonAttributes : self.sheetCancelButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
            
        } else if (alertAction.style == MBAlertActionStyleDestructive) {
            
            NSDictionary *attributes = (self.preferredStyle == MBAlertControllerStyleAlert) ? self.alertDestructiveButtonAttributes : self.sheetDestructiveButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
            
        } else {
            
            NSDictionary *attributes = (self.preferredStyle == MBAlertControllerStyleAlert) ? self.alertButtonAttributes : self.sheetButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
        }
        
        [alertAction.button setAttributedTitle:attributeString forState:UIControlStateNormal];
        
        NSDictionary *attributes = (self.preferredStyle == MBAlertControllerStyleAlert) ? self.alertButtonDisabledAttributes : self.sheetButtonDisabledAttributes;
        if (alertAction.buttonDisabledAttributes) {
            attributes = alertAction.buttonDisabledAttributes;
        }
        
        attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
        [alertAction.button setAttributedTitle:attributeString forState:UIControlStateDisabled];
        
        if ([alertAction.button imageForState:UIControlStateNormal]) {
            NSRange range = NSMakeRange(0, attributeString.length);
            UIColor *disabledColor = [attributeString attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&range];
            [alertAction.button setImage:[[alertAction.button imageForState:UIControlStateNormal] MB_imageWithTintColor:disabledColor] forState:UIControlStateDisabled];
        }
    }
}

- (NSArray<MBTextField *> *)textFields {
    return [self.alertTextFields copy];
}

- (void)handleMaskViewEvent:(id)sender {
    if (_shouldRespondMaskViewTouch) {
        [self hideWithAnimated:YES completion:NULL];
    }
}

#pragma mark - <MBAlertActionDelegate>

- (void)didClickAlertAction:(MBAlertAction *)alertAction {
    [self hideWithAnimated:YES completion:^{
        if (alertAction.handler) {
            alertAction.handler(self, alertAction);
        }
    }];
}

#pragma mark - <MBTextFieldDelegate>

- (BOOL)textFieldShouldReturn:(MBTextField *)textField {
    if (!self.shouldManageTextFieldsReturnEventAutomatically) {
        return NO;
    }
    
    if (![self.textFields containsObject:textField]) {
        return NO;
    }
    
    // 最后一个输入框，默认的 return 行为与 iOS 9-11 保持一致，也即：
    // 如果 action = 1，则自动响应这个 action 的事件
    // 如果 action = 2，并且其中有一个是 Cancel，则响应另一个 action 的事件，如果其中不存在 Cancel，则降下键盘，不响应任何 action
    // 如果 action > 2，则降下键盘，不响应任何 action
    if (textField == self.textFields.lastObject) {
        if (self.actions.count == 1) {
            [self.actions.firstObject.button sendActionsForControlEvents:UIControlEventTouchUpInside];
        } else if (self.actions.count == 2) {
            if (self.cancelAction) {
                MBAlertAction *targetAction = self.actions.firstObject == self.cancelAction ? self.actions.lastObject : self.actions.firstObject;
                [targetAction.button sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
        [self.view endEditing:YES];
        return NO;
    }
    // 非最后一个输入框，则默认的 return 行为是聚焦到下一个输入框
    NSUInteger index = [self.textFields indexOfObject:textField];
    [self.textFields[index + 1] becomeFirstResponder];
    return NO;
}

@end

@implementation MBAlertController (Manager)

+ (BOOL)isAnyAlertControllerVisible {
    return alertControllerCount > 0;
}

@end

