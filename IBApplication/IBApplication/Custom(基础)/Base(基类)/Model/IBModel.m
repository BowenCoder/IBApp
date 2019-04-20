//
//  IBModel.m
//  IBApplication
//
//  Created by Bowen on 2018/7/9.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBModel.h"

@implementation IBModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self yy_modelInitWithCoder:aDecoder];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

- (NSUInteger)hash {
    return [self yy_modelHash];
}

- (BOOL)isEqual:(id)object {
    return [self yy_modelIsEqual:object];
}


@end
