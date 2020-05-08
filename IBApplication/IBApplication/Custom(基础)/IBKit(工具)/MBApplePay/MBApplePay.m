//
//  MBApplePay.m
//  IBApplication
//
//  Created by BowenCoder on 2020/5/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBApplePay.h"

@interface MBApplePay ()<SKPaymentTransactionObserver, SKRequestDelegate, SKProductsRequestDelegate>

@property (nonatomic, strong) SKReceiptRefreshRequest *refreshReceiptRequest;
@property (nonatomic, strong) NSMutableDictionary *products;
@property (nonatomic, assign) NSInteger restoredTransactionsCount;
@property (nonatomic, assign) BOOL restoredTransactionsFinished;
@property (nonatomic, strong) NSMutableArray *restoredTransactions;

@end

@implementation MBApplePay

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.products = [NSMutableDictionary dictionary];
        self.restoredTransactionsCount = 0;
        self.restoredTransactions = [NSMutableArray array];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

+ (BOOL)canMakePayments
{
    return [SKPaymentQueue canMakePayments];
}

- (void)refreshReceipt
{
    self.refreshReceiptRequest = [[SKReceiptRefreshRequest alloc] init];
    self.refreshReceiptRequest.delegate = self;
    [self.refreshReceiptRequest start];
}

- (void)requestProducts:(NSSet *)identifiers
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)addPayment:(NSString *)productId
{
    SKProduct *product = [self productForIdentifier:productId];
    if (!product) {
        NSError *error = [NSError errorWithDomain:@"pay.error" code:MBApplePayErrorProductId userInfo:@{NSLocalizedDescriptionKey: @"Unknown product identifier"}];
        [self didFailTransaction:nil queue:nil error:error];
        return;
    }
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreTransactions
{
    self.restoredTransactionsFinished = NO;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (SKProduct *)productForIdentifier:(NSString*)productIdentifier
{
    return self.products[productIdentifier];
}

+ (NSURL *)receiptURL
{
    return [[NSBundle mainBundle] appStoreReceiptURL];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self didPurchaseTransaction:transaction queue:queue];
                break;
            case SKPaymentTransactionStateFailed:
                [self didFailTransaction:transaction queue:queue error:transaction.error];
                break;
            case SKPaymentTransactionStateRestored:
                [self didRestoreTransaction:transaction queue:queue];
                break;
            case SKPaymentTransactionStateDeferred:
                [self didDeferTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    self.restoredTransactionsFinished = YES;
    [self notifyRestoreTransactionFinished:nil];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(applePayRestoreTransactionsFailed:)]) {
        [self.delegate applePayRestoreTransactionsFailed:error];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    for (SKDownload *download in downloads)
    {
        switch (download.downloadState)
        {
            case SKDownloadStateActive:
                [self didUpdateDownload:download queue:queue];
                break;
            case SKDownloadStateCancelled:
                [self didCancelDownload:download queue:queue];
                break;
            case SKDownloadStateFailed:
                [self didFailDownload:download queue:queue];
                break;
            case SKDownloadStateFinished:
                [self didFinishDownload:download queue:queue];
                break;
            case SKDownloadStatePaused:
                [self didPauseDownload:download queue:queue];
                break;
            case SKDownloadStateWaiting:
                break;
        }
    }
}

#pragma mark - Transaction State

- (void)didPurchaseTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue
{
    if (self.receiptVerifier != nil) {
        [self.receiptVerifier verifyTransaction:transaction success:^{
            [self didDownloadContentForTransaction:transaction queue:queue];
        } failure:^(NSError *error) {
            [self didFailTransaction:transaction queue:queue error:error];
        }];
    } else {
        [self didDownloadContentForTransaction:transaction queue:queue];
    }
}

- (void)didFailTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue error:(NSError*)error
{
    if (error.code != MBApplePayErrorLaunchRetry && transaction) {
        [queue finishTransaction:transaction];
    }
    
    if (transaction.transactionState == SKPaymentTransactionStateRestored) {
        [self notifyRestoreTransactionFinished:transaction];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(applePayPaymentTransactionFailed:error:)]) {
            [self.delegate applePayPaymentTransactionFailed:transaction error:error];
        }
    }
}

- (void)didRestoreTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue
{
    self.restoredTransactionsCount++;
    if (self.receiptVerifier != nil) {
        [self.receiptVerifier verifyTransaction:transaction success:^{
            [self didDownloadContentForTransaction:transaction queue:queue];
        } failure:^(NSError *error) {
            [self didFailTransaction:transaction queue:queue error:error];
        }];
    } else {
        [self didDownloadContentForTransaction:transaction queue:queue];
    }
}

- (void)didDeferTransaction:(SKPaymentTransaction *)transaction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(applePayPaymentTransactionDeferred:)]) {
        [self.delegate applePayPaymentTransactionDeferred:transaction];
    }
}

- (void)didDownloadContentForTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue
{
    NSArray *downloads = [transaction respondsToSelector:@selector(downloads)] ? transaction.downloads : @[];
    if (downloads.count > 0) {
        [queue startDownloads:downloads];
    } else {
        [self finishTransaction:transaction queue:queue];
    }
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue
{
    [queue finishTransaction:transaction];
    
    if (transaction.transactionState == SKPaymentTransactionStateRestored) {
        [self notifyRestoreTransactionFinished:transaction];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(applePayPaymentTransactionFinished:)]) {
            [self.delegate applePayPaymentTransactionFinished:transaction];
        }
    }
}

- (void)notifyRestoreTransactionFinished:(SKPaymentTransaction*)transaction
{
    if (transaction) {
        [self.restoredTransactions addObject:transaction];
        self.restoredTransactionsCount--;
    }
    if (self.restoredTransactionsFinished && self.restoredTransactionsCount == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(applePayRestoreTransactionsFinished:)]) {
            [self.delegate applePayRestoreTransactionsFinished:self.restoredTransactions];
            [self.restoredTransactions removeAllObjects];
        }
    }
}

#pragma mark - Download State

- (void)didCancelDownload:(SKDownload *)download queue:(SKPaymentQueue *)queue
{
    SKPaymentTransaction *transaction = download.transaction;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(applePayDownloadCanceled:)]) {
        [self.delegate applePayDownloadCanceled:download];
    }
    
    BOOL hasPendingDownloads = [self hasDownloadsInTransaction:transaction];
    if (!hasPendingDownloads) {
        [self didFailTransaction:transaction queue:queue error:download.error];
    }
}

- (void)didFailDownload:(SKDownload *)download queue:(SKPaymentQueue *)queue
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(applePayDownloadFailed:)]) {
        [self.delegate applePayDownloadFailed:download];
    }
    
    SKPaymentTransaction *transaction = download.transaction;
    BOOL hasPendingDownloads = [self hasDownloadsInTransaction:transaction];
    if (!hasPendingDownloads) {
        [self didFailTransaction:transaction queue:queue error:download.error];
    }
}

- (void)didFinishDownload:(SKDownload *)download queue:(SKPaymentQueue *)queue
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(applePayDownloadFinished:)]) {
        [self.delegate applePayDownloadFinished:download];
    }
    
    SKPaymentTransaction *transaction = download.transaction;
    BOOL hasPendingDownloads = [self hasDownloadsInTransaction:transaction];
    if (!hasPendingDownloads) {
        [self finishTransaction:download.transaction queue:queue];
    }
}

- (void)didPauseDownload:(SKDownload *)download queue:(SKPaymentQueue *)queue
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(applePayDownloadPaused:)]) {
        [self.delegate applePayDownloadPaused:download];
    }
}

- (void)didUpdateDownload:(SKDownload *)download queue:(SKPaymentQueue *)queue
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(applePayDownloadUpdated:)]) {
        [self.delegate applePayDownloadUpdated:download];
    }
}

- (BOOL)hasDownloadsInTransaction:(SKPaymentTransaction *)transaction
{
    for (SKDownload *download in transaction.downloads)
    {
        switch (download.downloadState)
        {
            case SKDownloadStateActive:
            case SKDownloadStatePaused:
            case SKDownloadStateWaiting:
                return YES;
            case SKDownloadStateCancelled:
            case SKDownloadStateFailed:
            case SKDownloadStateFinished:
                continue;
        }
    }
    return NO;
}

#pragma mark - SKRequestDelegate

- (void)requestDidFinish:(SKRequest *)request
{
    if ([request isKindOfClass:SKReceiptRefreshRequest.class]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(applePayRefreshReceiptFinished:)]) {
            [self.delegate applePayRefreshReceiptFinished:request];
        }
    }
    if ([request isKindOfClass:SKProductsRequest.class]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(applePayProductsRequestFinished:)]) {
            [self.delegate applePayProductsRequestFinished:self.products.allValues];
        }
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if ([request isKindOfClass:SKReceiptRefreshRequest.class]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(applePayRefreshReceiptFailed:)]) {
            [self.delegate applePayRefreshReceiptFailed:error];
        }
    }
    if ([request isKindOfClass:SKProductsRequest.class]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(applePayProductsRequestFailed:)]) {
            [self.delegate applePayProductsRequestFailed:error];
        }
    }
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = [NSArray arrayWithArray:response.products];
    for (SKProduct *product in products) {
        self.products[product.productIdentifier] = product;
    }
}

@end
