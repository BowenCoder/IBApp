//
//  UIView+TrackData.h
//  IBApplication
//
//  Created by Bowen on 2020/1/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (TrackData)

+ (NSString *)viewPathForSender:(id)sender;

+ (NSString *)parentPathForComponent:(id)component;

+ (NSString *)indexForComponent:(id)component;

+ (NSString *)pathForComponent:(id)component;

+ (id)targetForView:(UIView *)view withClass:(Class)targetClass;

@end

NS_ASSUME_NONNULL_END
