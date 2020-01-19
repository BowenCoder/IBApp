//
//  UITableView+TrackData.m
//  IBApplication
//
//  Created by Bowen on 2020/1/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "UITableView+TrackData.h"
#import "RSSwizzle.h"
#import "UIView+TrackData.h"
#import "MBAutoTrackerUpload.h"

@implementation UITableView (TrackData)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [RSSwizzle swizzleInstanceMethod:@selector(setDelegate:) inClass:self newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
            return ^void(__unsafe_unretained id self, id<UITableViewDelegate> delegate) {
                // 调用之前方法
                void(*originalIMP)(__unsafe_unretained id, SEL, id);
                originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
                originalIMP(self, @selector(setDelegate:), delegate);
                // hook选中方法
                [self _hook_clickCellInTableView];
            };
        } mode:RSSwizzleModeAlways key:"app.trackdata.tableview.delegate"];
    });
}

- (void)_hook_clickCellInTableView
{
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        return;
    }
    
    [RSSwizzle swizzleInstanceMethod:@selector(tableView:didSelectRowAtIndexPath:)
                             inClass:[self.delegate class]
                       newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
        return ^void(__unsafe_unretained id self, UITableView *tableView, NSIndexPath *indexPath) {
            
            void(*originalIMP)(__unsafe_unretained id, SEL, id, id);
            originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
            originalIMP(self, @selector(tableView:didSelectRowAtIndexPath:), tableView, indexPath);
            NSString *viewPath = [UIView viewPathForSender:[tableView cellForRowAtIndexPath:indexPath]];
            [MBAutoTrackerUpload trackViewPath:viewPath];
        };
    } mode:RSSwizzleModeAlways key:"app.trackdata.tableview.click"];

}



@end
