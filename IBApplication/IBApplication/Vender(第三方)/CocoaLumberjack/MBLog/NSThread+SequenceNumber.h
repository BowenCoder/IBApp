//
//  NSThread+SequenceNumber.h
//  IBApplication
//
//  Created by Bowen on 2019/5/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSThread (SequenceNumber)

- (NSInteger)sequenceNumber;

@end

NS_ASSUME_NONNULL_END
