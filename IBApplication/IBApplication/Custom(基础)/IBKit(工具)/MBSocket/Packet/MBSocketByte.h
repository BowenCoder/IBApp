//
//  MBSocketByte.h
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBSocketByte : NSObject

@property (nonatomic, strong, readonly) NSMutableData *buffer;

- (instancetype)initWithData:(NSData *)data;
- (NSData *)data;
- (NSUInteger)length;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
