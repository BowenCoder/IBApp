//
//  IBUrlManager.h
//  IBApplication
//
//  Created by Bowen on 2019/6/30.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 url的获取，根据key获取url
 */
@interface IBUrlManager : NSObject

+ (instancetype)sharedInstance;

/// 服务数据准备（url, switche）
- (void)prepare;

/**
 *  更新线上URL配置(变动更新)
 *
 *  @param aConfig aConfig description
 *
 *  @return return value description
 */
- (NSDictionary *)updateUrlConfig:(NSDictionary *)aConfig;

/**
 *  获取指定key的URL
 *
 *  @param key key description
 *
 *  @return return value description
 */
- (NSString *)urlForKey:(NSString *)key;

/**
 *  获取指定key的switch
 *
 *  @param key key description
 *
 *  @return return value description
 */
- (BOOL)switchForKey:(NSString *)key;


#pragma mark - Url 地址拼接

/**
 *  获取最终的图片请求地址（支持裁剪的）默认质量80
 *
 *  @param url 图片地址
 *
 *  @param size 尺寸 (尺寸小于等于0时，取原图)
 *
 *  @return 返回最终的地址
 *
 */
- (NSString *)scaleImageUrl:(NSString *)url size:(CGSize)size;

/**
 *  获取最终的图片请求地址（支持裁剪的）
 *
 *  @param url 图片地址
 *
 *  @param size 尺寸 (尺寸小于等于0时，取原图)
 *
 *  @param quality 质量（取值范围1-100）
 *
 *  @return 返回最终的地址
 *
 */
- (NSString *)scaleImageUrl:(NSString *)url size:(CGSize)size quality:(NSInteger)quality;

/**
 * 补全图片地址
 */
- (NSString *)fullImageUrl:(NSString *)url;

/**
 *  补全视频文件地址
 */
- (NSString *)fullVideoUrl:(NSString *)url;

/**
 *  补全语音文件地址
 */
- (NSString *)fullVoiceUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
