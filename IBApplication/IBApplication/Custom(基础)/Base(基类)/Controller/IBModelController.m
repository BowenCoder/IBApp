//
//  IBModelController.m
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBModelController.h"
#import "MBProgressHUD+Ext.h"

@interface IBModelController ()

@property (nonatomic, strong) UIView *textView;

@end

@implementation IBModelController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidBeginEditingNotification
                                                  object:nil];
}


#pragma mark - 重写方法

#pragma mark - 公开方法

- (void)enterLoginVC {
    
}

- (void)pageLoad:(NSString *)url params:(NSDictionary *)params success:(HTTPClientSuccess)success failure:(HTTPClientError)failure isGet:(BOOL)isGet {
    
    [MBProgressHUD showTriangleLoadingView:self.view];
    if (isGet) {
        [IBHTTPClient GET:url send:nil params:params success:^(id JSON) {
            if (success) {
                success(JSON);
            }
            [MBProgressHUD hideTriangleLoadingView:self.view];
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
            [MBProgressHUD hideTriangleLoadingView:self.view];
            [MBProgressHUD showNoData:self.view reload:^{
                [self pageLoad:url params:params success:success failure:failure isGet:YES];
            }];
        }];
    } else {
        [IBHTTPClient POST:url send:nil params:params success:^(id JSON) {
            if (success) {
                success(JSON);
            }
            [MBProgressHUD hideTriangleLoadingView:self.view];
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
            [MBProgressHUD hideTriangleLoadingView:self.view];
            [MBProgressHUD showNoData:self.view reload:^{
                [self pageLoad:url params:params success:success failure:failure isGet:YES];
            }];
        }];
    }
}



#pragma mark - 私有方法
/**
 键盘通知关联方法
 
 通知连续执行两个解决办法
 设置
 spellCheckingType = UITextSpellCheckingTypeNo;
 autocorrectionType = UITextAutocorrectionTypeNo;
 */
- (void)ib_keyboardWillShow:(NSNotification *)noti {
    
    //1.获取键盘显示完毕后的Y值
    CGRect rectEnd = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = rectEnd.origin.y;
    CGRect rect = [self.textView.superview convertRect:self.textView.frame toView:self.view.superview];
    UIScrollView *superView = (UIScrollView*)[self superview:self.textView classType:[UIScrollView class]];
    if (superView) {
        CGFloat textViewY =  CGRectGetMaxY(rect);
        //用键盘的Y值减去屏幕的高度计算平移的值
        CGFloat transformValue = keyboardY - textViewY - 5;
        CGFloat shouldOffsetY = superView.contentOffset.y - MIN(superView.contentOffset.y, transformValue);
        [UIView animateWithDuration:0.25 animations:^{
            [superView setContentOffset:CGPointMake(superView.contentOffset.x, shouldOffsetY)];
        }];
    } else {
        CGFloat textViewY = CGRectGetMaxY(rect);
        if (keyboardY < textViewY) {
            //用键盘的Y值减去屏幕的高度计算平移的值
            CGFloat transformValue = keyboardY - textViewY - 5;
            [UIView animateWithDuration:0.25 animations:^{
                self.view.transform = CGAffineTransformMakeTranslation(0, transformValue);
            }];
        }
    }
}

- (void)ib_keyboardWillHide:(NSNotification *)noti {
    
    CGRect rectEnd = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = rectEnd.origin.y;
    CGRect rect = [self.textView.superview convertRect:self.textView.frame toView:self.view.superview];
    UIScrollView *superView = (UIScrollView*)[self superview:self.textView classType:[UIScrollView class]];
    if (superView) {
        CGFloat textViewY =  CGRectGetMaxY(rect);
        //用键盘的Y值减去屏幕的高度计算平移的值
        CGFloat transformValue = keyboardY - textViewY - 5;
        CGFloat shouldOffsetY = superView.contentOffset.y - MIN(superView.contentOffset.y, transformValue);
        [UIView animateWithDuration:0.25 animations:^{
            [superView setContentOffset:CGPointMake(superView.contentOffset.x, shouldOffsetY)];
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)ib_textViewDidBeginEditing:(NSNotification*)notification {
    self.textView = notification.object;
}

- (UIView *)superview:(UIView *)view classType:(Class)classType {
    
    UIView *superview = view.superview;
    while (superview) {
        if ([superview isKindOfClass:classType]) {
            if ([superview isKindOfClass:[UIScrollView class]]) {
                NSString *classNameString = NSStringFromClass([superview class]);
                if ([superview.superview isKindOfClass:[UITableView class]] == NO &&
                    [superview.superview isKindOfClass:[UITableViewCell class]] == NO &&
                    [classNameString hasPrefix:@"_"] == NO) {
                    return superview;
                }
            } else {
                return superview;
            }
        }
        superview = superview.superview;
    }
    return nil;
}


#pragma mark - 代理事件


#pragma mark - 合成存取

- (void)setOpenKeyListener:(BOOL)openKeyListener {
    
    _openKeyListener = openKeyListener;
    if (_openKeyListener) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ib_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ib_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ib_textViewDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    }
}


@end
