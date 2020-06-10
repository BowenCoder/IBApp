//
//  MBSocketByte.m
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketByte.h"

static NSInteger charByte     = 1;
static NSInteger shortByte    = 2;
static NSInteger intByte      = 4;
static NSInteger longByte     = 8;

@implementation MBSocketByte

- (instancetype)init
{    
    if (self = [super init]) {
        _buffer = [[NSMutableData alloc] init];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        _buffer = [[NSMutableData alloc] initWithData:data];
    }
    return self;
}

- (NSData *)data
{
    return _buffer;
}

- (NSUInteger)length
{
    return _buffer.length;
}

- (void)clear
{
    _buffer = [[NSMutableData alloc] init];
}

#pragma mark - NSInteger

- (void)writeInt8:(int8_t)value
{
    [_buffer appendBytes:&value length:charByte];
}

- (int8_t)readInt8:(NSUInteger)index
{
    int8_t val = 0;
    [_buffer getBytes:&val range:NSMakeRange(index, charByte)];
    return val;
}

- (void)replaceInt8:(int8_t)value index:(NSUInteger)index
{
    [_buffer replaceBytesInRange:NSMakeRange(index, charByte) withBytes:&value];
}

- (void)writeInt16:(int16_t)value htons:(BOOL)isUse
{
    value = isUse ? HTONS(value) : value;
    [_buffer appendBytes:&value length:shortByte];
}

- (int16_t)readInt16:(NSUInteger)index ntohs:(BOOL)isUse
{
    if (index + shortByte > _buffer.length) {
        return 0;
    }
    int16_t val = 0;
    [_buffer getBytes:&val range:NSMakeRange(index, shortByte)];
    return isUse ? NTOHS(val) : val;
}

- (void)replaceInt16:(int16_t)value index:(NSUInteger)index htons:(BOOL)isUse
{
    if (index + shortByte > _buffer.length) {
        return;
    }
    value = isUse ? HTONS(value) : value;
    [_buffer replaceBytesInRange:NSMakeRange(index, shortByte) withBytes:&value];
}

- (void)writeInt32:(int32_t)value htonl:(BOOL)isUse
{
    value = isUse ? HTONL(value) : value;
    [_buffer appendBytes:&value length:intByte];
}

- (int32_t)readInt32:(NSUInteger)index ntohl:(BOOL)isUse
{
    if (index + intByte > _buffer.length) {
        return 0;
    }
    int32_t val = 0;
    [_buffer getBytes:&val range:NSMakeRange(index, intByte)];
    return isUse ? NTOHL(val) : val;
}

- (void)replaceInt32:(int32_t)value index:(NSUInteger)index htonl:(BOOL)isUse
{
    if (index + intByte > _buffer.length) {
        return;
    }
    value = isUse ? HTONL(value) : value;
    [_buffer replaceBytesInRange:NSMakeRange(index, intByte) withBytes:&value];
}

- (void)writeInt64:(int64_t)value htonll:(BOOL)isUse
{
    value = isUse ? HTONLL(value) : value;
    [_buffer appendBytes:&value length:longByte];
}

- (int64_t)readInt64:(NSUInteger)index ntohll:(BOOL)isUse
{
    if (index + longByte > _buffer.length) {
        return 0;
    }
    int64_t val = 0;
    [_buffer getBytes:&val range:NSMakeRange(index, longByte)];
    return isUse ? NTOHLL(val) : val;
}

- (void)replaceInt64:(int64_t)value index:(NSUInteger)index htonll:(BOOL)isUse
{
    if (index + longByte > _buffer.length) {
        return;
    }
    value = isUse ? HTONLL(value) : value;
    [_buffer replaceBytesInRange:NSMakeRange(index, longByte) withBytes:&value];
}

#pragma mark - NSData

- (void)writeData:(NSData *)data
{
    if (data.length == 0) {
        return;
    }
    [_buffer appendData:data];
}

- (NSData *)readData:(NSUInteger)index length:(NSUInteger)length
{
    if (index + length > _buffer.length) {
        return nil;
    }
    NSRange range = NSMakeRange(index, length);
    NSData *data = [_buffer subdataWithRange:range];
    return data;
}

#pragma mark - NSString

- (void)writeString:(NSString *)string
{
    if (string.length == 0) {
        return;
    }
    [_buffer appendBytes:string.UTF8String length:string.length];
}

- (NSString *)readString:(NSUInteger)index length:(NSUInteger)length
{
    if (index + length > _buffer.length) {
        return nil;
    }
    NSData *data = [self readData:index length:length];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}


@end
