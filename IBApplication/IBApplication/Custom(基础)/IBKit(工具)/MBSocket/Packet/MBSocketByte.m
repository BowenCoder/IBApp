//
//  MBSocketByte.m
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBSocketByte.h"

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

@end
