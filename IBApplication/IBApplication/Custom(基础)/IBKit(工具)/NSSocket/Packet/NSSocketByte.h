//
//  NSSocketByte.h
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSocketByte : NSObject

@property (nonatomic, strong, readonly) NSMutableData *buffer;

- (instancetype)initWithData:(NSData *)data;
- (NSData *)data;
- (NSUInteger)length;
- (void)clear;

@end

@interface NSSocketByte (NSInteger)

- (void)writeInt8:(int8_t)param;
- (void)writeInt16:(int16_t)param useHost:(BOOL)isUse;
- (void)writeInt32:(int32_t)param useHost:(BOOL)isUse;
- (void)writeInt64:(int64_t)param;

- (int8_t)readInt8:(NSUInteger)index;
- (int16_t)readInt16:(NSUInteger)index;
- (int32_t)readInt32:(NSUInteger)index useHost:(BOOL)isUse;
- (int64_t)readInt64:(NSUInteger)index;

@end

@interface NSSocketByte (NSData)

- (void)writeData:(NSData *)param;

- (NSData *)readData:(NSUInteger)index length:(NSUInteger)length;

@end

@interface NSSocketByte (NSString)

- (void)writeString:(NSString *)param;

- (NSString *)readString:(NSUInteger)index length:(NSUInteger)length;

@end
