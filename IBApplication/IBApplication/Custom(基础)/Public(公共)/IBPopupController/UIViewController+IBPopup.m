//
//  UIViewController+IBPopup.m
//  IBPopup
//
//  Created by Bowen on 2018/8/21.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIViewController+IBPopup.h"
#import "IBPopupController.h"
#import <objc/runtime.h>

@implementation UIViewController (IBPopup)

@dynamic contentSizeInPopup;
@dynamic landscapeContentSizeInPopup;
@dynamic popupController;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(viewDidLoad) toSelector:@selector(ib_viewDidLoad)];
        [self swizzleSelector:@selector(presentViewController:animated:completion:) toSelector:@selector(ib_presentViewController:animated:completion:)];
        [self swizzleSelector:@selector(dismissViewControllerAnimated:completion:) toSelector:@selector(ib_dismissViewControllerAnimated:completion:)];
        [self swizzleSelector:@selector(presentedViewController) toSelector:@selector(ib_presentedViewController)];
        [self swizzleSelector:@selector(presentingViewController) toSelector:@selector(ib_presentingViewController)];
    });
}

+ (void)swizzleSelector:(SEL)originalSelector toSelector:(SEL)swizzledSelector
{
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)ib_viewDidLoad
{
    CGSize contentSize = CGSizeZero;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            contentSize = self.landscapeContentSizeInPopup;
            if (CGSizeEqualToSize(contentSize, CGSizeZero)) {
                contentSize = self.contentSizeInPopup;
            }
        }
            break;
        default: {
            contentSize = self.contentSizeInPopup;
        }
            break;
    }
    
    if (!CGSizeEqualToSize(contentSize, CGSizeZero)) {
        self.view.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    }
    [self ib_viewDidLoad];
}

- (void)ib_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    if (!self.popupController) {
        [self ib_presentViewController:viewControllerToPresent animated:flag completion:completion];
        return;
    }
    
    [[self.popupController valueForKey:@"containerViewController"] presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)ib_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    if (!self.popupController) {
        [self ib_dismissViewControllerAnimated:flag completion:completion];
        return;
    }
    
    [self.popupController dismissWithCompletion:completion];
}

- (UIViewController *)ib_presentedViewController
{
    if (!self.popupController) {
        return [self ib_presentedViewController];
    }
    return [[self.popupController valueForKey:@"containerViewController"] presentedViewController];
}

- (UIViewController *)ib_presentingViewController
{
    if (!self.popupController) {
        return [self ib_presentingViewController];
    }
    return [[self.popupController valueForKey:@"containerViewController"] presentingViewController];
}

- (void)setContentSizeInPopup:(CGSize)contentSizeInPopup
{
    if (!CGSizeEqualToSize(CGSizeZero, contentSizeInPopup) && contentSizeInPopup.width == 0) {
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight: {
                contentSizeInPopup.width = [UIScreen mainScreen].bounds.size.height;
            }
                break;
            default: {
                contentSizeInPopup.width = [UIScreen mainScreen].bounds.size.width;
            }
                break;
        }
    }
    objc_setAssociatedObject(self, @selector(contentSizeInPopup), [NSValue valueWithCGSize:contentSizeInPopup], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)contentSizeInPopup
{
    return [objc_getAssociatedObject(self, @selector(contentSizeInPopup)) CGSizeValue];
}

- (void)setLandscapeContentSizeInPopup:(CGSize)landscapeContentSizeInPopup
{
    if (!CGSizeEqualToSize(CGSizeZero, landscapeContentSizeInPopup) && landscapeContentSizeInPopup.width == 0) {
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight: {
                landscapeContentSizeInPopup.width = [UIScreen mainScreen].bounds.size.width;
            }
                break;
            default: {
                landscapeContentSizeInPopup.width = [UIScreen mainScreen].bounds.size.height;
            }
                break;
        }
    }
    objc_setAssociatedObject(self, @selector(landscapeContentSizeInPopup), [NSValue valueWithCGSize:landscapeContentSizeInPopup], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)landscapeContentSizeInPopup
{
    return [objc_getAssociatedObject(self, @selector(landscapeContentSizeInPopup)) CGSizeValue];
}

- (void)setPopupController:(IBPopupController *)popupController
{
    objc_setAssociatedObject(self, @selector(popupController), popupController, OBJC_ASSOCIATION_ASSIGN);
}

- (IBPopupController *)popupController
{
    IBPopupController *popupController = objc_getAssociatedObject(self, @selector(popupController));
    if (!popupController) {
        return self.parentViewController.popupController;
    }
    return popupController;
}

@end
