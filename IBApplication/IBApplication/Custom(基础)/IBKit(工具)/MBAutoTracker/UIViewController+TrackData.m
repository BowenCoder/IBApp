//
//  UIViewController+TrackData.m
//  IBApplication
//
//  Created by Bowen on 2020/1/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "UIViewController+TrackData.h"
#import "RSSwizzle.h"
#import "UIView+TrackData.h"
#import "MBAutoTrackerUpload.h"

@implementation UIViewController (TrackData)

+ (void)load
{
    [RSSwizzle swizzleInstanceMethod:@selector(viewDidAppear:) inClass:UIViewController.class newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
        return ^void(__unsafe_unretained UIViewController *controller, BOOL animated){
            void (*originalIMP)(__unsafe_unretained id, SEL, BOOL);
            originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
            originalIMP(self, @selector(viewDidAppear:), animated);
            NSString *currentTime = @([[NSDate date] timeIntervalSince1970] * 1000).stringValue;
            NSString *path = [self currentVCTracePathWithTarget:controller];
            [MBAutoTrackerUpload trackPageInWithName:NSStringFromClass(controller.class) time:currentTime enterPath:path];
        };
    } mode:RSSwizzleModeAlways key:"app.trackdata.controller.viewDidAppear"];
    
    [RSSwizzle swizzleInstanceMethod:@selector(viewDidDisappear:) inClass:[UIViewController class] newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
        return ^void(__unsafe_unretained UIViewController *controller, BOOL animated) {
            void (*originalIMP)(__unsafe_unretained id, SEL, BOOL);
            originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
            originalIMP(self, @selector(viewDidDisappear:), animated);
            NSString *currentTime = @([[NSDate date] timeIntervalSince1970] * 1000).stringValue;
            [MBAutoTrackerUpload trackPageOutWithName:NSStringFromClass(controller.class) time:currentTime];
        };
    } mode:RSSwizzleModeAlways key:"app.trackdata.controller.viewDidDisappear"];
}

+ (NSString *)currentVCTracePathWithTarget:(UIViewController *)targetVC {
    if (!targetVC) {
        return nil;
    }
    
    NSMutableString *path = [NSMutableString new];
    UIViewController *target = targetVC;
        
    if ([target isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)target;
        target = nav.viewControllers.lastObject;
    }
    
    NSArray *vcNames = [self enterNamesWithVC:target];
    for (int i = 0; i < [vcNames count]; i++) {
        if (i != 0) {
            [path appendString:@"-"];
        }
        [path appendString:vcNames[i]];
    }
    
    return path;
}

+ (NSMutableArray *)enterNamesWithVC:(UIViewController *)vc {
    NSMutableArray *names = [NSMutableArray new];
    NSMutableArray *vcs = [self tracingVCsWithTarget:vc fromType:0];
    NSMutableArray *newVCs = [NSMutableArray new];
    [newVCs addObjectsFromArray:vcs];
    
    [vcs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBarController = obj;
            id selectedVC = tabBarController.selectedViewController;
            if (selectedVC) {
                if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                    UINavigationController *nav = selectedVC;
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(idx+1, [nav.viewControllers count])];
                    [newVCs insertObjects:nav.viewControllers atIndexes:indexSet];
                } else {
                    [newVCs insertObject:selectedVC atIndex:idx+1];
                }
            }
            if (tabBarController.presentedViewController) {
                [newVCs addObject:tabBarController.presentedViewController];
            }
        }
    }];
    
    // 去重
    NSOrderedSet *orderedNewVCsSet = [NSOrderedSet orderedSetWithArray:newVCs];
    NSArray *orderedNewVCsArray = [orderedNewVCsSet array];
    
    for (id vc in orderedNewVCsArray) {
        if ([vc isKindOfClass:[NSString class]]) {
            [names addObject:vc];
        } else {
            [names addObject:NSStringFromClass([vc class])];
        }
    }
    
    return names;
}

+ (NSMutableArray *)tracingVCsWithTarget:(UIViewController *)target fromType:(NSUInteger)fromType {
    NSMutableArray *vcs = [NSMutableArray new];
    
    if (target.navigationController && [target.navigationController.viewControllers count] > 0 && fromType != 1) {
        if ([target.navigationController.viewControllers containsObject:target]) {
            NSInteger indexOfTarget = [target.navigationController.viewControllers indexOfObject:target];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, indexOfTarget + 1)];
            [vcs insertObjects:[target.navigationController.viewControllers objectsAtIndexes:indexSet] atIndexes:indexSet];
        } else {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [target.navigationController.viewControllers count])];
            [vcs insertObjects:target.navigationController.viewControllers atIndexes:indexSet];
        }
        
        NSMutableArray *vcsFromFirst = [self tracingVCsWithTarget:vcs[0] fromType:1];
        if ([vcsFromFirst count] > 0) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [vcsFromFirst count])];
            [vcs insertObjects:vcsFromFirst atIndexes:indexSet];
        }
    } else if (target.presentingViewController) {
        if ([target.presentingViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navCtrl = (UINavigationController *)target.presentingViewController;
            NSArray *items = navCtrl.viewControllers;
            
            if (items && [items count] > 0) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [items count])];
                [vcs insertObjects:items atIndexes:indexSet];
                
                NSMutableArray *vcsFromFirst = [self tracingVCsWithTarget:vcs[0] fromType:1];
                NSIndexSet *indexSetForFirst = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [vcsFromFirst count])];
                [vcs insertObjects:vcsFromFirst atIndexes:indexSetForFirst];
            }
        } else if (target.presentingViewController) {
            [vcs insertObject:target.presentingViewController atIndex:0];
            
            NSMutableArray *vcsFromFirst = [self tracingVCsWithTarget:target.presentingViewController fromType:2];
            if ([vcsFromFirst count] > 0) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [vcsFromFirst count])];
                [vcs insertObjects:vcsFromFirst atIndexes:indexSet];
            }
        }
    }
    return vcs;
}

@end
