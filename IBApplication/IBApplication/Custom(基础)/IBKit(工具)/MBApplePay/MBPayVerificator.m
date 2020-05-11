//
//  MBPayVerificator.m
//  MBApplePay
//
//  Created by Bowen on 2020/5/8.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBPayVerificator.h"
#import "MBAppStorePayLog.h"
#import "MBPayOrderItem.h"
#import "MBPayOrderIDCache.h"
#import "MBPayDelegate.h"
#import "MBUserManager.h"
#import "MBLogger.h"
#import "IBMacros.h"
#import "IBHTTPClient.h"

NSString * const kVerifyReceiptUrl = @"kApplePayVerifyReceiptUrl";

@implementation MBPayVerificator

- (void)verifyTransaction:(SKPaymentTransaction*)transaction
                  success:(void (^)(void))successBlock
                  failure:(void (^)(NSError *error))failureBlock
{
    MBPayOrderItem *item = [MBPayOrderIDCache orderWithProductId:transaction.payment.productIdentifier];
    if (!item) {
        item = [[MBPayOrderItem alloc] init];
        item.productId = transaction.payment.productIdentifier;
    }
    
    if (kIsEmptyString(item.transactionIdentifier)) {
        item.transactionIdentifier = transaction.transactionIdentifier;
    }
    
    if (kIsEmptyString(item.originTransationId)) {
        item.originTransationId = [self originalTransactionIdentifier:transaction];
    }
    
    // 保存完整交易信息
    [MBPayOrderIDCache addOrder:item];
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    NSString *receiptStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    if (kIsEmptyString(receiptStr)) {
        NSError *error = [NSError errorWithDomain:@"invalid recipt" code:MBPAYERROR_APPLEORDERINVALID userInfo:nil];
        if (failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"receipt_data"] = NSStringNONil(receiptStr);
    dic[@"order"] = NSStringNONil(item.orderId);
    dic[@"order_uid"] = @([NSStringNONil(item.uid) integerValue]);
    dic[@"apple_product_id"] = NSStringNONil(item.productId);
    dic[@"original_transaction_id"] = NSStringNONil(item.originTransationId);

    [self checkReceiptWithOrderItem:item body:dic success:successBlock failure:failureBlock];
}

- (void)checkReceiptWithOrderItem:(MBPayOrderItem *)orderItem
                             body:(NSDictionary *)body
                          success:(void (^)(void))successBlock
                          failure:(void (^)(NSError *error))failureBlock
{
    
    NSString *url = [[IBUrlManager sharedInstance] urlForKey:kVerifyReceiptUrl];
    
    __weak typeof(self) weakSelf = self;
    
    [IBHTTPManager POST:url params:nil body:body completion:^(IBURLErrorCode errorCode, IBURLResponse *response) {
        
        NSString *errMsg = response.message;
        
        if (errorCode == IBURLErrorSuccess) {
            if (successBlock) {
                successBlock();
            }
            [weakSelf removeOrder:orderItem];
        } else {
            NSError *error;
            if (errorCode == IBURLErrorService || errorCode == IBURLErrorUnknown ||
                (errorCode >= NSURLErrorBadServerResponse && errorCode <= NSURLErrorCancelled)) {
                error = [NSError errorWithDomain:response.message
                                            code:MBApplePayErrorLaunchRetry
                                        userInfo:nil];
            } else {
                [weakSelf removeOrder:orderItem];
                error = [NSError errorWithDomain:response.message
                                            code:MBPAYERROR_SERVERCHECKFAIL
                                        userInfo:nil];
            }
            if (failureBlock) {
                failureBlock(error);
            }
        }
        
        [MBAppStorePayLog trackAgreeWithProductId:orderItem.productId order:orderItem.orderId transactionId:orderItem.transactionIdentifier errCode:errorCode errMsg:errMsg body:body];
    }];
}

- (void)removeOrder:(MBPayOrderItem *)item
{
    // 移除消耗性商品
    if (item.productType == MBPayProductType_ConsumableItem) {
        [MBPayOrderIDCache deleteOrder:item];
    }
}

- (NSString *)originalTransactionIdentifier:(SKPaymentTransaction *)transaction
{
    NSString *transactionId = transaction.originalTransaction.transactionIdentifier;
    if (kIsEmptyString(transactionId)) {
        transactionId = transaction.transactionIdentifier;
    }
    return transactionId;
}

@end
