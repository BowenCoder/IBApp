//
//  MBPayRequest.h
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MBPayProductType) {
    MBPayProductType_ConsumableItem,            // 消耗型项目
    MBPayProductType_NonExpendableItem,         // 非消耗型项目
    MBPayProductType_AutoRenewSubscription,     // 自动续期订阅
    MBPayProductType_NonRenewalSubscription,    // 非续期订阅
};

@interface MBPayProduct : NSObject

@property (nonatomic, copy) NSString *productId;
@property (nonatomic, assign) MBPayProductType productType; // 苹果支付类型
@property (nonatomic, assign) float money; // 实际支付的RMB/美元，单位：分/美分 埋点用

@end

@interface MBPayRequest : NSObject

@property (nonatomic, strong) MBPayProduct *product; // 商品信息
@property (nonatomic, copy) NSString *url;           // 创建订单的url
@property (nonatomic, copy) NSDictionary *params;    // 自定义post的params
@property (nonatomic, copy) NSDictionary *body;      // 自定义post的body
@property (nonatomic, copy) NSString *orderParseKey; // 解析的keyPath 如ios_sub.order

@end


