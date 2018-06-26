//
//  NSData+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/6/22.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSData+Ext.h"

@implementation NSData (Ext)

/**
 *  @brief  NSData 转成UTF8 字符串
 *
 *  @return 转成UTF8字符串
 */
-(NSString *)UTF8String {
    
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}


@end

