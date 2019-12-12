//
//  IBSecurity.m
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBSecurity.h"

@interface IBSecurity ()

@property (nonatomic, strong) NSMutableDictionary *headerDict;

@end

@implementation IBSecurity

- (void)requestData
{
    
}

- (NSDictionary *)headerFields
{
    return self.headerDict;
}

#pragma mark - getter

- (NSMutableDictionary *)headerDict {
    if(!_headerDict){
        _headerDict = [NSMutableDictionary dictionary];
    }
    return _headerDict;
}

@end
