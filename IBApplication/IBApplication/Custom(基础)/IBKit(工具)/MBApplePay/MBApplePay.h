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
    MBApplePayErrorNoProduct   = 10000,     //商品不存在
    MBApplePayErrorLaunchRetry = 10001,     //启动重试
};

NS_ASSUME_NONNULL_BEGIN

@protocol MBPayReceiptVerifier <NSObject>

- (void)verifyTransaction:(SKPaymentTransaction *)transaction
                  success:(void (^)(void))successBlock
                  failure:(void (^)(NSError *error))failureBlock;

@end

@protocol MBApplePayDelegate <NSObject>

@optional

//====================== SKDownload ====================//

/// 托管内容下载取消
- (void)applePayDownloadCanceled:(SKDownload *)download;

/// 托管内容下载失败
- (void)applePayDownloadFailed:(SKDownload *)download;

/// 托管内容下载完成
- (void)applePayDownloadFinished:(SKDownload *)download;

/// 托管内容下载暂停
- (void)applePayDownloadPaused:(SKDownload *)download;

/// 托管内容下载更新
- (void)applePayDownloadUpdated:(SKDownload *)download;

//====================== Payment ====================//

/// 最终状态未确定
- (void)applePayPaymentTransactionDeferred:(SKPaymentTransaction *)transaction;

/// 支付失败
- (void)applePayPaymentTransactionFailed:(SKPaymentTransaction *)transaction error:(NSError *)error;

/// 支付成功
- (void)applePayPaymentTransactionPaySuccess:(SKPaymentTransaction *)transaction;

/// 票据验证成功 && 托管内容下载完成
- (void)applePayPaymentTransactionFinished:(SKPaymentTransaction *)transaction;

//====================== ProductsRequest ====================//

/// 商品请求失败
- (void)applePayProductsRequestFailed:(NSError *)error;

/// 商品请求完成
- (void)applePayProductsRequestFinished:(NSDictionary *)products;

//====================== RefreshReceipt ====================//

/// 刷新票据失败
- (void)applePayRefreshReceiptFailed:(NSError *)error;

/// 刷新票据完成
- (void)applePayRefreshReceiptFinished:(SKRequest *)request;

//====================== Restore ====================//

/// 恢复购买失败
- (void)applePayRestoreTransactionsFailed:(NSError *)error;

/// 恢复购买完成
- (void)applePayRestoreTransactionsFinished:(NSArray<SKPaymentTransaction *> *)transactions;

//====================== shouldAddStorePayment ====================//

/// 自动下单
- (BOOL)applePayShouldAddStorePayment:(SKPayment *)payment product:(SKProduct *)product;

@end


@interface MBApplePay : NSObject

@property (nonatomic, weak) id<MBApplePayDelegate> delegate;

@property (nonatomic, weak) id<MBPayReceiptVerifier> receiptVerifier;

+ (BOOL)canMakePayments;

- (void)refreshReceipt;

- (void)requestProducts:(NSSet *)identifiers;

- (void)addPayment:(NSString *)productId;

- (void)restoreTransactions;

- (SKProduct *)productForIdentifier:(NSString*)productIdentifier;

+ (NSURL *)receiptURL;

@end

NS_ASSUME_NONNULL_END
