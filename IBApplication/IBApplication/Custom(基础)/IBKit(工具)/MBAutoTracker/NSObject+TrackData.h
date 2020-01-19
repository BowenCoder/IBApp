//
//  NSObject+TrackData.h
//  IBApplication
//
//  Created by Bowen on 2020/1/19.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 暂未实现
@interface NSObject (TrackData)

@property (nonatomic, assign) BOOL ignoreTracking;

@property (nonatomic, copy) NSDictionary *trackingData;

@end

NS_ASSUME_NONNULL_END
