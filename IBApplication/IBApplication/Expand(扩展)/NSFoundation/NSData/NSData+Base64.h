//
//  NSData+Base64.h
//  IBApplication
//
//  Created by Bowen on 2018/6/22.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSData (Base64)

/**
 *  @brief  base64字符串解码
 *
 *  @param string base64字符串
 *
 *  @return 返回解码后的data
 */
+ (NSData *)decodeBase64:(NSString *)string;
/**
 *  @brief  NSData转string 换行长度默认64
 *
 *  @return base64后的字符串
 */
- (NSString *)encodeBase64;
/**
 *  @brief  NSData 转成UTF8 字符串
 *
 *  @return 转成UTF8 字符串
 */
- (NSString *)UTF8String;


@end
