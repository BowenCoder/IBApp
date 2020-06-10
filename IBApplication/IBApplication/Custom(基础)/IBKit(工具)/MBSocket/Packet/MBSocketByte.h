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

#pragma mark - NSInteger

- (void)writeInt8:(int8_t)value;

- (int8_t)readInt8:(NSUInteger)index;

- (void)replaceInt8:(int8_t)value index:(NSUInteger)index;

- (void)writeInt16:(int16_t)value htons:(BOOL)isUse;

- (int16_t)readInt16:(NSUInteger)index ntohs:(BOOL)isUse;

- (void)replaceInt16:(int16_t)value index:(NSUInteger)index htons:(BOOL)isUse;

- (void)writeInt32:(int32_t)value htonl:(BOOL)isUse;

- (int32_t)readInt32:(NSUInteger)index ntohl:(BOOL)isUse;

- (void)replaceInt32:(int32_t)value index:(NSUInteger)index htonl:(BOOL)isUse;

- (void)writeInt64:(int64_t)value htonll:(BOOL)isUse;

- (int64_t)readInt64:(NSUInteger)index ntohll:(BOOL)isUse;

- (void)replaceInt64:(int64_t)value index:(NSUInteger)index htonll:(BOOL)isUse;

#pragma mark - NSData

- (void)writeData:(NSData *)data;

- (NSData *)readData:(NSUInteger)index length:(NSUInteger)length;

#pragma mark - NSString

- (void)writeString:(NSString *)string;

- (NSString *)readString:(NSUInteger)index length:(NSUInteger)length;

@end


/**
 
 n --> network
 h --> host
 s --> short
 l --> long
 
 ntohs()  将一个无符号短整形数从网络字节顺序转换为主机字节顺序。
 
 ntohl()  将一个无符号长整形数从网络字节顺序转换为主机字节顺序。
 
 ntohll() 将一个无符号长长整形数从网络字节顺序转换为主机字节顺序
 
 htons()  将主机的无符号短整形数转换成网络字节顺序。
 
 htonl()  将主机的无符号长整形数转换成网络字节顺序。
 
 htonll()  将主机的无符号长长整形数转换成网络字节顺序。
 
 */

NS_ASSUME_NONNULL_END
