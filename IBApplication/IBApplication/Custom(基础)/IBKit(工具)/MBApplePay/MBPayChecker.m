//
//  MBPayChecker.m
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import "MBPayChecker.h"
#import "MBAppStorePayLog.h"
#import "MBPayOrderItem.h"
#import "MBApplePayModel.h"
#import "IBMacros.h"
#import "IBHTTPClient.h"
#import "NSDictionary+Ext.h"
#import "MBUserManager.h"
#import "MBLogger.h"
#import "MBPayOrderIDCache.h"

@interface MBPayChecker ()

@property (nonatomic, assign) NSInteger retryTime;
@property (nonatomic, assign) BOOL isStopped;

@end

@implementation MBPayChecker
@synthesize product;
@synthesize checkSuccessBlock;
@synthesize checkErrorBlock;
@synthesize deleteCheckerBlock;

#pragma mark - out

+ (void)checkUnFinishedOrder
{
    NSArray *items = [MBPayOrderIDCache allOrders];
    for (MBPayOrderItem *item in items) {
        [MBPayChecker checkOrder:item];
    }
}

- (void)stopRetry
{
    self.isStopped = YES;
}

- (void)checkReceiptWithOrderItem:(MBPayOrderItem *)orderItem
{
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    NSString *receiptStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    MBLogI(@"#apple.pay# name:recipt value:%@",receiptStr);
    
    if (kIsEmptyString(receiptStr)) {
        if (self.checkErrorBlock) {
            self.checkErrorBlock(MBPAYERROR_APPLEORDERINVALID);
        }
        return;
    }
    
    // 保存完整交易信息
    [MBPayOrderIDCache addOrder:orderItem];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"receipt_data"] = NSStringNONil(receiptStr);
    dic[@"order"] = NSStringNONil(orderItem.orderId);
    dic[@"order_uid"] = @([NSStringNONil(orderItem.uid) integerValue]);
    dic[@"apple_product_id"] = NSStringNONil(orderItem.productId);
    dic[@"original_transaction_id"] = NSStringNONil(orderItem.originTransationId);
    
    [self sendPaymentNoticeRequest:dic orderItem:orderItem];

}

- (void)sendPaymentNoticeRequest:(NSDictionary *)body orderItem:(MBPayOrderItem *)orderItem
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *url = [[IBUrlManager sharedInstance] urlForKey:kVerifyReceiptUrl];
    
    __weak typeof(self) weakSelf = self;
    
    [IBHTTPManager POST:url params:nil body:params completion:^(IBURLErrorCode errorCode, IBURLResponse *response) {
        
        NSString *errMsg = response.message;
        
        if (errorCode == IBURLErrorSuccess) {
            if (weakSelf.checkSuccessBlock) {
                weakSelf.checkSuccessBlock(orderItem.orderId);
            }
            [weakSelf removeOrder:orderItem];
        } else {
            if (errorCode == IBURLErrorService || errorCode == IBURLErrorTimeout ||
                errorCode == IBURLErrorUnknown || errorCode == IBURLErrorNetworkLost) {
                [weakSelf retry:body orderItem:orderItem];
            } else {
                [weakSelf removeOrder:orderItem];
                if (weakSelf.checkErrorBlock) {
                    weakSelf.checkErrorBlock(MBPAYERROR_SERVERCHECKFAIL);
                }
            }
        }
        
        [MBAppStorePayLog trackAgreeWithProductId:weakSelf.product.productId order:orderItem.orderId transactionId:orderItem.transactionIdentifier errCode:errorCode errMsg:errMsg body:body];
    }];
}

// 重试逻辑
- (void)retry:(NSDictionary *)body orderItem:(MBPayOrderItem *)orderItem
{
    self.retryTime++;
    
    if (self.retryTime > 3 && self.checkErrorBlock) {
        self.checkErrorBlock(MBPAYERROR_RETRYFAIL);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.retryTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.isStopped) {
            return;
        }
        [weakSelf sendPaymentNoticeRequest:body orderItem:orderItem];
    });
}

- (void)removeOrder:(MBPayOrderItem *)item
{
    // 移除消耗性商品
    if (item.productType == MBPayProductType_ConsumableItem) {
        [MBPayOrderIDCache deleteOrder:item];
    }
    
    if (self.deleteCheckerBlock) {
        self.deleteCheckerBlock(self);
    }
}

+ (void)checkOrder:(MBPayOrderItem *)orderItem
{
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    NSString *receiptStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    if (kIsEmptyString(receiptStr)) {
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"receipt_data"] = NSStringNONil(receiptStr);
    dic[@"order"] = NSStringNONil(orderItem.orderId);
    dic[@"order_uid"] = @([NSStringNONil(orderItem.uid) integerValue]);
    dic[@"apple_product_id"] = NSStringNONil(orderItem.productId);
    dic[@"original_transaction_id"] = NSStringNONil(orderItem.originTransationId);
    
    NSString *url = [[IBUrlManager sharedInstance] urlForKey:kVerifyReceiptUrl];
    [IBHTTPManager POST:url params:nil body:dic completion:^(IBURLErrorCode errorCode, IBURLResponse * _Nonnull response) {
        MBLogI(@"#apple.pay# name:launch.verify.success value:%@",dic);
    }];
    
}

@end
