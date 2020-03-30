//
//  NSMethodSignature+Ext.h
//  IBApplication
//
//  Created by Bowen on 2020/3/30.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMethodSignature (Ext)

/**
 返回一个避免 crash 的方法签名，用于重写 methodSignatureForSelector: 时作为垫底的 return 方案
 */
@property(nullable, class, nonatomic, readonly) NSMethodSignature *fb_avoidExceptionSignature;

/**
 以 NSString 格式返回当前 NSMethodSignature 的 typeEncoding，例如 v@:
 */
@property(nullable, nonatomic, copy, readonly) NSString *fb_typeString;

/**
 以 const char 格式返回当前 NSMethodSignature 的 typeEncoding，例如 v@:
 */
@property(nullable, nonatomic, readonly) const char *fb_typeEncoding;

@end

NS_ASSUME_NONNULL_END
