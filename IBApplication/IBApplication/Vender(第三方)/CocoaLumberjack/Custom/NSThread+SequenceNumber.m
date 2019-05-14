//
//  NSThread+SequenceNumber.m
//  IBApplication
//
//  Created by Bowen on 2019/5/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "NSThread+SequenceNumber.h"

@implementation NSThread (SequenceNumber)

- (NSInteger)sequenceNumber
{
    return [[self valueForKeyPath:@"private.seqNum"] unsignedIntegerValue];
}

@end
