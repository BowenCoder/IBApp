//
//  IBSocialDelegate.h
//  IBApplication
//
//  Created by Bowen on 2018/8/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IBSocialDelegate <NSObject>

@optional

- (void)auth:(id)result error:(NSError *)error;

- (void)share:(id)result error:(NSError *)error;

- (void)bind:(id)result error:(NSError *)error;

@end
