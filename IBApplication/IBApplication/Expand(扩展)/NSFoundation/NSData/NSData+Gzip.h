//
//  NSData+Gzip.h
//  IBApplication
//
//  Created by Bowen on 2018/6/22.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Gzip)

/**
 *  @brief  compressedData 压缩后的数据
 *
 *  @return 是否压缩
 */
- (BOOL)isGzippedData:(NSData *)compressedData;

/**
 *  @brief  GZIP压缩 压缩级别 默认-1
 *
 *  @return 压缩后的数据
 */
- (NSData *)gzippedData;

/**
 *  @brief  GZIP解压
 *
 *  @return 解压后数据
 */
- (NSData *)gunzippedData;

@end
