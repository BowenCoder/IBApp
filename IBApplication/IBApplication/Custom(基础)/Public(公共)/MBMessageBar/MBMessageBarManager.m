//
//  MBMessageBarManager.m
//  IBApplication
//
//  Created by Bowen on 2020/1/6.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBMessageBarManager.h"
#import "MBMessageBarView.h"

CGFloat const kMBMessageBarAnimationDuration = 0.3f;
CGFloat const KMBMessageBarDisplayDuration = 3.0f;

#pragma mark - Window

@interface MBMessageBarWindow : UIWindow

@end

@implementation MBMessageBarWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if ([hitView isEqual:self.rootViewController.view]) {
        hitView = nil;
    }
    return hitView;
}

@end

#pragma mark - ViewController

@interface MBMessageBarViewController : UIViewController

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, assign) BOOL statusBarHidden;

@end

@implementation MBMessageBarViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
    _statusBarStyle = statusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden
{
    _statusBarHidden = statusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return self.statusBarHidden;
}

@end

#pragma mark - manager


@interface MBMessageBarManager ()

@property (nonatomic, strong) NSMutableArray *messageBarQueue;
@property (nonatomic, strong) MBMessageBarWindow *messageWindow;
@property (nonatomic, assign) BOOL messageVisible;

@end

@implementation MBMessageBarManager

+ (MBMessageBarManager *)sharedInstance
{
    static MBMessageBarManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MBMessageBarManager alloc] init];
    });
    return manager;
}

- (void)showMessage:(NSString *)message callback:(nullable void (^)(void))callback
{
    [self showMessageWithTitle:nil message:message image:nil callback:callback];
}

- (void)showMessageWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)iconImage callback:(nullable void (^)(void))callback;
{
    [self showMessageWithTitle:title message:message image:iconImage type:MBMessageBarStyleTypeCustom duration:KMBMessageBarDisplayDuration callback:callback];
}

- (void)showMessageWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)iconImage type:(MBMessageBarStyleType)type duration:(CGFloat)duration callback:(void (^)(void))callback
{
    [self showMessageWithTitle:title message:message image:iconImage type:type duration:duration statusBarHidden:NO statusBarStyle:UIStatusBarStyleDefault callback:callback];
}

- (void)showMessageWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)iconImage type:(MBMessageBarStyleType)type statusBarHidden:(BOOL)statusBarHidden callback:(void (^)(void))callback
{
    [self showMessageWithTitle:title message:message image:iconImage type:type duration:KMBMessageBarDisplayDuration statusBarHidden:statusBarHidden statusBarStyle:UIStatusBarStyleDefault callback:callback];
}

- (void)showMessageWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)iconImage type:(MBMessageBarStyleType)type statusBarStyle:(UIStatusBarStyle)statusBarStyle callback:(void (^)(void))callback
{
    [self showMessageWithTitle:title message:message image:iconImage type:type duration:KMBMessageBarDisplayDuration statusBarHidden:NO statusBarStyle:statusBarStyle callback:callback];
}

- (void)showMessageWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)iconImage type:(MBMessageBarStyleType)type duration:(CGFloat)duration statusBarHidden:(BOOL)statusBarHidden statusBarStyle:(UIStatusBarStyle)statusBarStyle callback:(void (^)(void))callback
{
    self.style.customIconImage = iconImage;
    MBMessageBarView *messageView = [[MBMessageBarView alloc] init];
    messageView.hidden = YES;
    messageView.title = title;
    messageView.message = message;
    messageView.style = self.style;
    messageView.position = self.position;
    messageView.messageType = type;
    messageView.duration = duration;
    messageView.statusBarHidden = statusBarHidden;
    messageView.statusBarStyle = statusBarStyle;
    messageView.onClickCallback = callback;
    [messageView setupView];
    
    [[self messageWindowView] insertSubview:messageView atIndex:0];
    [self.messageBarQueue addObject:messageView];
    
    if (!self.messageVisible) {
        [self showNextMessage];
    }
}

- (void)hideAllAnimated:(BOOL)animated
{
    for (UIView *subview in [[self messageWindowView] subviews]) {
        if ([subview isKindOfClass:[MBMessageBarView class]]) {
            MBMessageBarView *currentMessageView = (MBMessageBarView *)subview;
            if (animated) {
                [UIView animateWithDuration:kMBMessageBarAnimationDuration animations:^{
                    currentMessageView.frame = CGRectMake(currentMessageView.frame.origin.x, -currentMessageView.frame.size.height, currentMessageView.frame.size.width, currentMessageView.frame.size.height);
                } completion:^(BOOL finished) {
                    [currentMessageView removeFromSuperview];
                }];
            } else {
                [currentMessageView removeFromSuperview];
            }
        }
    }
    self.messageVisible = NO;
    [self.messageBarQueue removeAllObjects];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.messageWindow.hidden = YES;
    self.messageWindow = nil;
}

- (void)showNextMessage
{
    if ([self.messageBarQueue count] > 0) {
        MBMessageBarView *messageView = [self.messageBarQueue objectAtIndex:0];
        [self messageBarViewController].statusBarStyle = messageView.statusBarStyle;
        [self messageBarViewController].statusBarHidden = messageView.statusBarHidden;
        CGRect messageFrame = messageView.frame;
        CGRect tempFrame = messageFrame;
        tempFrame.origin.y = -messageFrame.size.height;
        messageView.frame = tempFrame;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMessageBarView:)];
        [messageView addGestureRecognizer:tap];
        messageView.hidden = NO;
        self.messageVisible = YES;
        if (messageView) {
            [UIView animateWithDuration:kMBMessageBarAnimationDuration animations:^{
                messageView.frame = messageFrame;
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(messageView.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dismissMessageBarView:messageView];
                });
            }];
        }
    } else {
        [self hideAllAnimated:NO];
    }
}

- (void)dismissMessageBarView:(id)sender
{
    MBMessageBarView *messageView = nil;
    if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
        messageView = (MBMessageBarView *)((UIGestureRecognizer *)sender).view;
    } else if ([sender isKindOfClass:[MBMessageBarView class]]) {
        messageView = (MBMessageBarView *)sender;
    }
    
    if (!messageView || ![self.messageBarQueue containsObject:messageView]) {
        return;
    }
    
    [self.messageBarQueue removeObject:messageView];
    
    [UIView animateWithDuration:kMBMessageBarAnimationDuration animations:^{
        messageView.frame = CGRectMake(messageView.frame.origin.x, -messageView.frame.size.height, messageView.frame.size.width, messageView.frame.size.height);
    } completion:^(BOOL finished) {
        if (messageView.onClickCallback) {
            messageView.onClickCallback();
        }
        [messageView removeFromSuperview];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kMBMessageBarAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.messageVisible = NO;
            [self showNextMessage];
        });
    }];
}

#pragma mark - getter

- (UIView *)messageWindowView {
    return [self messageBarViewController].view;
}

- (MBMessageBarViewController *)messageBarViewController {
    return (MBMessageBarViewController *)self.messageWindow.rootViewController;
}

- (MBMessageBarWindow *)messageWindow {
    if(!_messageWindow){
        _messageWindow = [[MBMessageBarWindow alloc] init];
        _messageWindow.frame = [UIApplication sharedApplication].keyWindow.frame;
        _messageWindow.hidden = NO;
        _messageWindow.windowLevel = UIWindowLevelNormal;
        _messageWindow.backgroundColor = [UIColor clearColor];
        _messageWindow.rootViewController = [[MBMessageBarViewController alloc] init];
    }
    return _messageWindow;
}

- (id<MBMessageBarStyleProtocol>)style {
    if(!_style){
        _style = [[MBMessageBarStyle alloc] init];
    }
    return _style;
}

- (NSMutableArray *)messageBarQueue {
    if(!_messageBarQueue){
        _messageBarQueue = [NSMutableArray array];
    }
    return _messageBarQueue;
}

@end
