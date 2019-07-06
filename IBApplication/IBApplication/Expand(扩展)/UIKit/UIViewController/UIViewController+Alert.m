//
//  UIViewController+Alert.m
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "UIViewController+Alert.h"
#import "IBMacros.h"

#define NO_USE -1000

static OnClickHandler clickIndex = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation UIViewController (Alert)

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                    others:(NSArray<NSString *> *)others
                  animated:(BOOL)animated
                    action:(OnClickHandler)click {
    
    if (kIsEmptyString(title) || kIsEmptyArray(others)) {
        return;
    }
    
    NSString *cancelTitle = others[0];
    NSMutableArray *otherTitles = others.mutableCopy;
    [otherTitles removeObjectAtIndex:0];
    
    if ([UIDevice currentDevice].systemVersion.floatValue < 8) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:nil];
        for (NSString *title in otherTitles) {
            [alertView addButtonWithTitle:title];
        }
        clickIndex = click;
        [alertView show];
        
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (click) {
                click(0);
            }
        }]];
        
        [otherTitles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [alert addAction:[UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (click) {
                    click(idx+1);
                }
            }]];
        }];
        
        [self presentViewController:alert animated:animated completion:nil];
    }
    
}

- (void)showActionSheetWithTitle:(NSString *)title
                         message:(NSString *)message
                     destructive:(NSString *)destructive
                          others:(NSArray <NSString *> *)others
                        animated:(BOOL)animated
                          action:(OnClickHandler)click {
    
    if (kIsEmptyString(title) || kIsEmptyArray(others)) {
        return;
    }
    NSString *cancelTitle = others[0];
    NSMutableArray *otherTitles = others.mutableCopy;
    [otherTitles removeObjectAtIndex:0];
    
    if ([UIDevice currentDevice].systemVersion.floatValue < 8) {
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:destructive otherButtonTitles:nil];;
        [otherTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [action addButtonWithTitle:obj];
        }];
        clickIndex = click;
        [action showInView:self.view];
        
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (click) {
                click(1);
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:destructive style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (click) {
                click(0);
            }
        }]];
        [otherTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [alert addAction:[UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (click) {
                    click(idx+2);
                }
            }]];
        }];
        [self presentViewController:alert animated:animated completion:nil];
    }
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                    others:(NSArray<NSString *> *)others
                  tfNumber:(NSInteger)number
                  tfHandle:(TFHandle)handle
                  animated:(BOOL)animated
                    action:(OnClickHandler)click {
    
    if (kIsEmptyString(title) || kIsEmptyArray(others)) {
        return;
    }
    
    NSString *cancelTitle = others[0];
    NSMutableArray *otherTitles = others.mutableCopy;
    [otherTitles removeObjectAtIndex:0];
    
    if ([UIDevice currentDevice].systemVersion.floatValue < 8) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:nil];
        for (NSString *title in otherTitles) {
            [alertView addButtonWithTitle:title];
        }
        if (number <= 1) {
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            handle([alertView textFieldAtIndex:0],0);
        } else {
            alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
            handle([alertView textFieldAtIndex:0],0);
            handle([alertView textFieldAtIndex:1],1);
        }
        clickIndex = click;
        [alertView show];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        for (NSInteger i = 0; i < number; i++) {
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                handle(textField,i);
            }];
        }
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (click) {
                click(0);
            }
        }]];
        [otherTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [alert addAction:[UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (click) {
                    click(idx+1);
                }
            }]];
        }];
        [self presentViewController:alert animated:animated completion:nil];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (clickIndex) {
        clickIndex(buttonIndex);
    }
    clickIndex = nil;
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (clickIndex) {
        clickIndex(buttonIndex);
    }
    clickIndex = nil;
}

@end

#pragma clang diagnostic pop

