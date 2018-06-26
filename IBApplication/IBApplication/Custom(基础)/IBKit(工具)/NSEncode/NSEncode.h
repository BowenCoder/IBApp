//
//  NSEncode.h
//  IBApplication
//
//  Created by Bowen on 2018/6/26.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSEncode : NSObject

//计算NSData的MD5值
+ (NSString*)md5WithData:(NSData*)data;

//计算大文件的MD5值
+ (NSString*)md5WithFile:(NSString*)path;

@end
