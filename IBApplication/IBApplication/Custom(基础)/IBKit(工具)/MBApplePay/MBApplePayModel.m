//
//  MBApplePayModel.m
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import "MBApplePayModel.h"
#import "MBApplePay.h"
#import "MBPayOrderIDCache.h"
#import "MBLogger.h"
#import "MBAppStorePayLog.h"
#import "IBHTTPClient.h"
#import "MBJailbroken.h"
#import "MBPayVerificator.h"

@interface MBApplePayModel () <MBApplePayDelegate>

@property (nonatomic, strong) MBApplePay *applePay;
@property (nonatomic, strong) MBPayVerificator *verificator;
@property (nonatomic, strong) MBPayProduct *product;
@property (nonatomic, assign) BOOL paying;
@property (nonatomic, assign) BOOL requestProduct;

@end

@implementation MBApplePayModel

#pragma mark - life circle

- (instancetype)init
{
    if (self = [super init]) {
        self.verificator = [[MBPayVerificator alloc] init];
        self.applePay = [[MBApplePay alloc] init];
        self.applePay.receiptVerifier = self.verificator;
        self.applePay.delegate = self;
    }
    return self;
}

#pragma mark - public

- (void)prepareAppleProducts:(NSArray<MBPayProduct *> *)products
{
    MBLogI(@"#apple.pay# name:prepare.apple.products");

    NSMutableSet *set = [NSMutableSet set];
    
    for (MBPayProduct *product in products) {
        NSString *appleProductId = product.productId;
        [set addObject:appleProductId];
    }
    
    [self.applePay requestProducts:set];
}

- (void)createPaymentWithProduct:(MBPayRequest *)request
{
    __weak typeof(self) weakSelf = self;
    
    NSString *pid = request.product.productId;
    BOOL hasOneOrder = [MBPayOrderIDCache hasOneOrderWithProductId:pid uid:request.product.uid];
    // 检查用户权限
    if ([MBApplePay canMakePayments]) {
        [self checkJailbroken:^(BOOL jailbroken) {
            if (jailbroken) {
                [weakSelf dealWithError:MBPAYERROR_JAILBROKEN msg:nil];
            } else {
                if (weakSelf.paying == YES || hasOneOrder) {
                    [weakSelf dealWithError:MBPAYERROR_PAYING msg:nil];
                } else {
                    [weakSelf requestOrderIdForCreatePayment:request];
                }
            }
        }];
    } else {
        [weakSelf dealWithError:MBPAYERROR_NOPERMISSION msg:nil];
    }
}

- (void)restoreApplePay
{
    MBLogI(@"#apple.pay# name:restoreTransactions");
    
    [self.applePay restoreTransactions];
}

- (void)requestOrderIdForCreatePayment:(MBPayRequest *)request
{
    self.paying = YES;

    [IBHTTPManager POST:request.url params:nil body:request.params completion:^(IBURLErrorCode errorCode, IBURLResponse *response) {
        NSString *orderId = @"";
        NSString *errMsg = response.message;
        
        if (errorCode == IBURLErrorSuccess) {
            orderId = [response.dict valueForKey:@"order_id"];
        }
        
        if (orderId.length > 0) {
            request.product.orderId = orderId;
            [self requestAppleProduct:request.product];
            if (self.delegate && [self.delegate respondsToSelector:@selector(orderCreated:)]) {
                [self.delegate orderCreated:orderId];
            }
        } else {
            [self dealWithError:MBPAYERROR_CREATEFAIL msg:errMsg];
        }
        
        [MBAppStorePayLog trackCreateWithProductId:request.product.productId order:orderId money:request.product.money errCode:errorCode errMsg:errMsg];
    }];
}

- (void)requestAppleProduct:(MBPayProduct *)product
{
    self.product = product;
    self.requestProduct = YES;

    SKProduct *skproduct = [self.applePay productForIdentifier:product.productId];
    
    if (skproduct != nil && [skproduct isKindOfClass:[SKProduct class]]) {
        [self startApplePayWithProduct:product];
    } else {
        [self prepareAppleProducts:@[product]];
    }
}

- (void)startApplePayWithProduct:(MBPayProduct *)product
{
    self.requestProduct = NO;

    MBPayOrderItem *item = [[MBPayOrderItem alloc] init];
    item.uid = product.uid;
    item.orderId = product.orderId;
    item.productType = product.productType;
    item.productId = product.productId;
    
    [MBPayOrderIDCache addOrder:item];
    
    [self.applePay addPayment:product.productId];
    
    [MBAppStorePayLog trackStartPayWithProductId:product.productId order:product.orderId];
}

#pragma mark - MBApplePayDelegate

/// 商品请求失败
- (void)applePayProductsRequestFailed:(NSError *)error
{
    if (self.product && self.requestProduct) {
        [MBAppStorePayLog trackRequestFailedWithProductId:self.product.productId order:self.product.orderId errCode:MBPAYERROR_NOPRODUCT errMsg:@"商品不存在"];
        [self dealWithError:MBPAYERROR_NOPRODUCT msg:nil];
    }
}

/// 商品请求完成
- (void)applePayProductsRequestFinished:(NSDictionary *)products
{
    if (self.product && self.requestProduct) {
        [self startApplePayWithProduct:self.product];
    }
}

/// 最终状态未确定
- (void)applePayPaymentTransactionDeferred:(SKPaymentTransaction *)transaction
{
    [self dealWithApplePayFailureWithTransaction:transaction error:transaction.error];
}

/// 支付失败
- (void)applePayPaymentTransactionFailed:(SKPaymentTransaction *)transaction error:(NSError *)error
{
    [self dealWithApplePayFailureWithTransaction:transaction error:error];
}

/// 支付成功
- (void)applePayPaymentTransactionPaySuccess:(SKPaymentTransaction *)transaction
{
    MBPayOrderItem *item = [MBPayOrderIDCache orderWithProductId:transaction.payment.productIdentifier];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(paymentResult:success:)]) {
            [self.delegate paymentResult:item success:YES];
        }
    });
    
    [MBAppStorePayLog trackIAPWithProductId:item.productId order:item.orderId transactionId:item.transactionIdentifier errCode:0 errMsg:@"支付成功"];
}

/// 票据验证成功 && 托管内容下载完成
- (void)applePayPaymentTransactionFinished:(SKPaymentTransaction *)transaction
{
    MBPayOrderItem *item = [MBPayOrderIDCache orderWithProductId:transaction.payment.productIdentifier];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(paymentVerifyReceipt:)]) {
            [self.delegate paymentVerifyReceipt:item];
        }
    });
    
    self.paying = NO;
    self.product = nil;
}

/// 恢复购买失败
- (void)applePayRestoreTransactionsFailed:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(paymentRestoreFailed:)]) {
            [self.delegate paymentRestoreFailed:error];
        }
    });
}

/// 恢复购买完成
- (void)applePayRestoreTransactionsFinished:(NSArray<SKPaymentTransaction *> *)transactions
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(paymentRestoreFinished)]) {
            [self.delegate paymentRestoreFinished];
        }
    });
}

- (void)dealWithApplePayFailureWithTransaction:(SKPaymentTransaction *)transaction error:(NSError *)error
{
    MBPayOrderItem *item;
    if (transaction) {
        item = [MBPayOrderIDCache orderWithProductId:transaction.payment.productIdentifier];
    } else {
        item = [MBPayOrderIDCache orderWithProductId:self.product.productId];
    }
    
    NSInteger errCode = error.code;
    NSString *errMsg = error.localizedDescription;
    
    if (errCode == SKErrorPaymentCancelled || errCode == -2) {
        [self dealWithError:MBPAYERROR_USERCANCLE msg:nil];
        [MBAppStorePayLog trackUserCancelWithProductId:item.productId order:item.orderId];
    } else {
        [self dealWithError:MBPAYERROR_APPLECONNECTFAIL msg:nil];
        [MBAppStorePayLog trackIAPWithProductId:item.productId order:item.orderId transactionId:item.transactionIdentifier errCode:errCode errMsg:errMsg];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(paymentResult:success:)]) {
            [self.delegate paymentResult:item success:NO];
        }
    });
}

#pragma mark - private

- (void)checkJailbroken:(void(^)(BOOL jailbroken))complete
{
    [MBJailbroken checkJailbroken:^(BOOL jailbroken, NSString * _Nonnull msg) {
        MBLogI(@"#apple.pay# name:jailbroken %@", msg);
        if (complete) {
            complete(jailbroken);
        }
    }];
}

- (void)dealWithError:(MBPAYERROR)error msg:(NSString *)msg
{
    self.paying = NO;
    self.product = nil;
    self.requestProduct = NO;
    
    switch (error)
    {
        case MBPAYERROR_JAILBROKEN:
        {
            msg = @"当前设备不支持内购";
        }
            break;
        case MBPAYERROR_PAYING:
        {
            msg = @"当前有一笔支付正在进行，稍候重试";
        }
            break;
        case MBPAYERROR_NOPERMISSION:
        {
            if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 12.0) {
                msg = @"打开:设置-屏幕使用时间-内容和隐私访问限制-App store购买项目-App内购买项目";
            } else {
                msg = @"打开:用户设置-通用-访问限制-app内购项目";
            }
        }
            break;
        case MBPAYERROR_CREATEFAIL:
        {
            msg = @"创建订单失败";
        }
            break;
        case MBPAYERROR_APPLETIMEOUT:
        {
            msg = @"连接超时，请检查后重试";
        }
            break;
        case MBPAYERROR_APPLECONNECTFAIL:
        {
            msg = @"App Store服务器无响应，请重试";
        }
            break;
        case MBPAYERROR_NOPRODUCT:
        {
            msg = @"App Store服务器获取商品失败，请重试";
        }
            break;
        case MBPAYERROR_USERCANCLE:
        {
            msg = @"用户中途取消支付";
        }
            break;
        case MBPAYERROR_RETRYFAIL:
        {
            msg = @"支付已完成，稍后到账";
        }
            break;
        case MBPAYERROR_APPLEORDERINVALID:
        case MBPAYERROR_SERVERCHECKFAIL:
        case MBPAYERROR_OTHER:
        {
            msg = @"支付失败，请联系客服";
        }
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(paymentFailWithType:errMsg:)]) {
            [self.delegate paymentFailWithType:error errMsg:msg];
        }
    });
}

@end
