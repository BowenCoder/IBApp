//
//  MBApplePay.h
//  IBApplication
//
//  Created by BowenCoder on 2020/5/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef NS_ENUM(NSInteger , MBApplePayError){
    MBApplePayErrorProductId   = 1000,     //未知商品Id
    MBApplePayErrorLaunchRetry = 1001,     //启动重试
    MBApplePayDownloadCanceled = 1002,     //下载取消
};


NS_ASSUME_NONNULL_BEGIN

@protocol MBPayContentDownloader <NSObject>

- (void)downloadContentForTransaction:(SKPaymentTransaction*)transaction
                              success:(void (^)(void))successBlock
                             progress:(void (^)(float progress))progressBlock
                              failure:(void (^)(NSError *error))failureBlock;

@end


@protocol MBPayReceiptVerificator <NSObject>

- (void)verifyTransaction:(SKPaymentTransaction *)transaction
                  success:(void (^)(void))successBlock
                  failure:(void (^)(NSError *error))failureBlock;

@end

@protocol MBApplePayDelegate <NSObject>

- (void)applePayDownloadCanceled:(SKDownload *)download;

- (void)applePayDownloadFailed:(SKDownload *)download;

- (void)applePayDownloadFinished:(SKDownload *)download;

- (void)applePayDownloadPaused:(SKDownload *)download;

- (void)applePayDownloadUpdated:(SKDownload *)download;

- (void)applePayPaymentTransactionDeferred:(SKPaymentTransaction *)transaction;

- (void)applePayPaymentTransactionFailed:(SKPaymentTransaction *)transaction error:(NSError *)error;

- (void)applePayPaymentTransactionFinished:(SKPaymentTransaction *)transaction;

- (void)applePayProductsRequestFailed:(NSError *)error;

- (void)applePayProductsRequestFinished:(NSArray<SKProduct *> *)products;

- (void)applePayRefreshReceiptFailed:(NSError *)error;

- (void)applePayRefreshReceiptFinished:(SKRequest *)request;

- (void)applePayRestoreTransactionsFailed:(NSError *)error;

- (void)applePayRestoreTransactionsFinished:(NSArray<SKPaymentTransaction *> *)transactions;

@end


@interface MBApplePay : NSObject

@property (nonatomic, weak) id<MBApplePayDelegate> delegate;

@property (nonatomic, weak) id<MBPayReceiptVerificator> receiptVerifier;

+ (BOOL)canMakePayments;

- (void)refreshReceipt;

- (void)requestProducts:(NSSet *)identifiers;

- (void)addPayment:(NSString *)productId;

- (void)restoreTransactions;

- (SKProduct *)productForIdentifier:(NSString*)productIdentifier;

+ (NSURL *)receiptURL;

@end

NS_ASSUME_NONNULL_END
