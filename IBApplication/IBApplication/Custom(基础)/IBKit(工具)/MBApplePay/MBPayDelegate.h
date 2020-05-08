//
//  MBPayDelegate.h
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef IKPayDelegate_h
#define IKPayDelegate_h

@class MBPayOrderItem;

typedef NS_ENUM(NSInteger , MBPAYERROR){
    MBPAYERROR_JAILBROKEN        = 0,     //越狱
    MBPAYERROR_NOPERMISSION      = 1,     //用户关闭支付
    MBPAYERROR_CREATEFAIL        = 2,     //创建订单失败
    MBPAYERROR_APPLETIMEOUT      = 3,     //苹果连接超时
    MBPAYERROR_APPLECONNECTFAIL  = 4,     //苹果连接失败
    MBPAYERROR_NOPRODUCT         = 5,     //请求苹果 获取商品列表失败
    MBPAYERROR_USERCANCLE        = 6,     //用户取消
    MBPAYERROR_APPLEORDERINVALID = 7,     //苹果支付成功 但是返回订单号非法
    MBPAYERROR_SERVERCHECKFAIL   = 8,     //服务校验票据失败
    MBPAYERROR_GOLDNOTARRIVE     = 9,     //服务校验票据重试失败 金币稍后到账
    MBPAYERROR_OTHER             = 10,    //其他情况
    MBPAYERROR_PAYING            = 12,     //支付中
};

@protocol MBPayDelegate <NSObject>

@optional

/// 订单创建成功回调
- (void)orderCreated:(NSString *)orderId;

/// 付款成功回调
- (void)applePayResult:(MBPayOrderItem *)orderItem isSuccess:(BOOL)isSuccess;

/// 验证成功回调
- (void)paymentCompletion:(BOOL)isSuccess orderBusDic:(NSDictionary *)orderBusDic orderItem:(MBPayOrderItem *)orderItem;

/// 失败回调
- (void)paymentFailWithType:(MBPAYERROR)type code:(NSInteger)error errMsg:(NSString *)errMsg;


@end

#endif /* MBPayDelegate_h */
