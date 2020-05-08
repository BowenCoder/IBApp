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
#import "IBFile.h"
#import "NSDictionary+Ext.h"
#import "MBUserManager.h"
#import "MBLogger.h"

@interface MBPayChecker ()

@property (nonatomic, assign) NSInteger retryTime;
@property (nonatomic, assign) BOOL isStopped;

@end

@implementation MBPayChecker

#pragma mark - out

- (void)checkCachedReceiptWithDic:(NSDictionary *)tmpDic
{
    NSString *orderId = [MBPayChecker orderidFromDic:tmpDic];
    NSString *transactionid = [MBPayChecker transactionidFromDic:tmpDic];
    NSDictionary *param = [MBPayChecker paramFromDic:tmpDic];
    [self checkLocalOrderId:orderId transactionId:transactionid param:param];
}

- (void)checkLocalOrderId:(NSString *)orderId transactionId:(NSString *)transactionid param:(NSDictionary *)paramDict
{
    [self sendPaymentNoticeRequest:paramDict transactionId:transactionid orderId:orderId];
}

- (void)stopRetry
{
    self.isStopped = YES;
}

- (void)checkOrderIdWithServer:(SKPaymentTransaction *)transaction orderId:(NSString *)orderId uid:(NSString *)uid orderItem:(MBPayOrderItem *)orderItem
{
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    NSString *receiptStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *transactionIdentifier = transaction.transactionIdentifier;
    
    MBLogI(@"#apple.pay# name:recipt value:%@",receiptStr);
    
    if (kIsEmptyString(receiptStr)) {
        if (self.checkErrorBlock) {
            self.checkErrorBlock(MBPAYERROR_APPLEORDERINVALID);
        }
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"receipt_data"] = NSStringNONil(receiptStr);
    dic[@"order"] = NSStringNONil(orderId);
    dic[@"order_uid"] = @([NSStringNONil(uid) integerValue]);
    dic[@"apple_product_id"] = NSStringNONil(transaction.payment.productIdentifier);
    dic[@"apple_introductory_price"] = @(orderItem.introductoryPrice);
    
    if (transaction.originalTransaction) {
        dic[@"original_transaction_id"] = NSStringNONil(transaction.originalTransaction.transactionIdentifier);
    }else {
        dic[@"original_transaction_id"] = NSStringNONil(transaction.transactionIdentifier);
    }
    
    [self sendPaymentNoticeRequest:dic transactionId:transactionIdentifier orderId:orderId];
}

- (void)sendPaymentNoticeRequest:(NSDictionary *)body transactionId:(NSString *)transactionid orderId:(NSString *)orderId
{
    if (self.isStopped) {
        return;
    }
    
    if (self.retryTime == 0) {
        [MBPayChecker saveOrderIdToLocal:body transactionId:transactionid orderId:orderId];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *url = [[IBUrlManager sharedInstance] urlForKey:kVerifyReceiptUrl];
    
    __weak typeof(self) weakSelf = self;
    
    [IBHTTPManager POST:url params:nil body:params completion:^(IBURLErrorCode errorCode, IBURLResponse *response) {
        
        NSString *errMsg = response.message;
        
        if (errorCode == IBURLErrorSuccess) {
            if (weakSelf.checkSuccessBlock) {
                weakSelf.checkSuccessBlock(orderId);
            }
            
            [MBPayChecker deleteOrderIdFromLocal:orderId];
            [weakSelf deleteOrder];
        } else {
            if (errorCode == IBURLErrorService || errorCode == IBURLErrorTimeout ||
                errorCode == IBURLErrorUnknown || errorCode == IBURLErrorNetworkLost) {
                [weakSelf retry:body transactionId:transactionid orderId:orderId];
                if (weakSelf.checkErrorBlock) {
                    weakSelf.checkErrorBlock(MBPAYERROR_GOLDNOTARRIVE);
                }
            } else {
                [weakSelf deleteOrder];
                if (weakSelf.checkErrorBlock) {
                    weakSelf.checkErrorBlock(MBPAYERROR_SERVERCHECKFAIL);
                }
            }
        }
        
        [MBAppStorePayLog trackAgreeWithProductId:weakSelf.product.productId order:orderId transactionId:transactionid errCode:errorCode errMsg:errMsg body:body];
    }];
}

// 重试逻辑
- (void)retry:(NSDictionary *)body transactionId:(NSString *)transactionid orderId:(NSString *)orderId
{
    __weak typeof(self) weakSelf = self;
    
    self.retryTime++;
    
    NSInteger deltTime = self.retryTime >= 3 ? 60 : 1;
    
    if (self.retryTime == 3 && self.checkErrorBlock) {
        self.checkErrorBlock(MBPAYERROR_GOLDNOTARRIVE);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(deltTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.isStopped == YES) {
            return;
        }
        [weakSelf sendPaymentNoticeRequest:body transactionId:transactionid orderId:orderId];
    });
}

- (void)deleteOrder
{
    [self stopRetry];
    
    if (self.deleteOrderBlock) {
        self.deleteOrderBlock(self);
    }
}

#pragma mark - local storeage

+ (void)saveOrderIdToLocal:(NSDictionary *)orderDic transactionId:(NSString *)transactionid orderId:(NSString *)orderId
{
    NSString *orderJson = [IBSerialization serializeJsonStringWithDict:orderDic];
    NSData *tiddata = [transactionid dataUsingEncoding:NSUTF8StringEncoding];
    NSString *Encodedtid = [tiddata base64EncodedStringWithOptions:0];
    
    NSDictionary *toCacheDict = @{@"id":NSStringNONil(orderId), @"order":NSStringNONil(orderJson), @"tid":NSStringNONil(Encodedtid)};
    
    NSArray *cachedArr = [self ordersFromLocal];
    NSMutableArray *newArr;
    
    if (cachedArr != nil && [cachedArr isKindOfClass:[NSArray class]]) {
        newArr = [cachedArr mutableCopy];
        
        for (NSDictionary *tmpDict in newArr) {
            if (tmpDict && [[tmpDict valueForKey:@"order"] isEqualToString:orderJson]) {
                return;
            }
        }
    } else {
        newArr = [NSMutableArray array];
    }
    
    [newArr addObject:toCacheDict];
    
    NSString *filePath = [IBFile filePathInDataDirInLibrary:[self orderCacheFileName]];
    [IBFile writeFileAtPath:filePath content:newArr error:nil];
}

+ (void)deleteOrderIdFromLocal:(NSString *)orderId
{
    NSArray *cachedArr = [self ordersFromLocal];
    NSMutableArray *newCacheArr = [NSMutableArray array];
    
    if (cachedArr != nil && [cachedArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *tmpDict in cachedArr) {
            if (tmpDict && ![[tmpDict valueForKey:@"id"] isEqualToString:orderId]) {
                [newCacheArr addObject:tmpDict];
            }
        }
    }
    
    NSString *filePath = [IBFile filePathInDataDirInLibrary:[self orderCacheFileName]];
    [IBFile writeFileAtPath:filePath content:newCacheArr error:nil];
}

+ (NSArray *)ordersFromLocal
{
    NSString *oidcachepath = [IBFile filePathInDataDirInLibrary:[self orderCacheFileName]];
    NSArray *array = [NSArray arrayWithContentsOfFile:oidcachepath];
    
    return array;
}

+ (NSString *)transactionidFromDic:(NSDictionary *)dic
{
    NSString *encodeTid = [dic valueForKey:@"tid"];
    
    if (encodeTid != nil) {
        NSData *data = [[NSData alloc]initWithBase64EncodedString:encodeTid options:0];
        
        if (data != nil) {
            return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}

+ (NSString *)orderidFromDic:(NSDictionary *)dic
{
    return [dic valueForKey:@"id"];
}

+ (NSDictionary *)paramFromDic:(NSDictionary *)dic
{
    NSString *paramsStr = [dic valueForKey:@"order"];
    
    if (paramsStr != nil) {
        return [IBSerialization unSerializeWithJsonString:paramsStr error:nil];
    }
    
    return nil;
}

+ (NSString *)orderCacheFileName
{
    return [NSString stringWithFormat:@"cacheorder_%ld.plist", (long)[MBUserManager sharedManager].loginUser.uid];
}

+ (void)checkLocalSubscribeOrder:(MBPayOrderItem *)orderItem
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
