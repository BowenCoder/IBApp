//
//  UICollectionView+TrackData.m
//  IBApplication
//
//  Created by Bowen on 2020/1/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "UICollectionView+TrackData.h"
#import "RSSwizzle.h"
#import "UIView+TrackData.h"
#import "MBAutoTrackerUpload.h"

@implementation UICollectionView (TrackData)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RSSwizzleInstanceMethod(self,
                                @selector(setDelegate:),
                                RSSWReturnType(void),
                                RSSWArguments(id<UICollectionViewDelegate> delegate),
                                RSSWReplacement({
            RSSWCallOriginal(delegate);
            [self _hook_clickCellInCollectionView];
        }), RSSwizzleModeAlways, "app.trackdata.collection.delegate")
    });
}

- (void)_hook_clickCellInCollectionView
{
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        return;
    }
    RSSwizzleInstanceMethod([self.delegate class],
                            @selector(collectionView:didSelectItemAtIndexPath:),
                            RSSWReturnType(void),
                            RSSWArguments(UICollectionView *collectionView, NSIndexPath *indexPath),
                            RSSWReplacement({
        RSSWCallOriginal(collectionView, indexPath);
        NSString *viewPath = [UIView viewPathForSender:[collectionView cellForItemAtIndexPath:indexPath]];
        [MBAutoTrackerUpload trackViewPath:viewPath];
    }), RSSwizzleModeAlways, "app.trackdata.collection.click");
}

@end
