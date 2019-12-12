//
//  IBNetworkConfig.h
//  IBApplication
//
//  Created by Bowen on 2019/6/17.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IBNetworkConfig : NSObject

/** 入网通道代码 */
+ (NSString *)channelCode;

/** 入网身份代码 */
+ (NSString *)licenseCode;

/** 项目代号 */
+ (NSString *)projectCode;

/** 协议版本 */
+ (NSString *)protoVersion;

/** 项目版本 */
+ (NSString *)clientVersion;

/** 系统版本 */
+ (NSString *)systemVersion;

/** 手机类型 */
+ (NSString *)iPhoneType;

/** 设备名称 */
+ (NSString *)deviceName;

/** 广告商的标志符 */
+ (NSString *)idfa;

/** 供应商的标志符 */
+ (NSString *)idfv;

/** 局域网名称 */
+ (NSString *)wifiESSID;

/** 站点的 MAC 地址 */
+ (NSString *)wifiBSSID;

/** serviceinfo地址 */
+ (NSString *)enterUrl;

/** serviceinfo备份地址 */
+ (NSString *)backupUrl;

/** 内置服务 */
+ (NSDictionary *)serviceInfo;

@end

NS_ASSUME_NONNULL_END
