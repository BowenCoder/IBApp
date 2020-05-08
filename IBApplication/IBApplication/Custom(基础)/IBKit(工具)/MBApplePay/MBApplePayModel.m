//
//  MBApplePayModel.m
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import "MBApplePayModel.h"
#import "RMStore.h"
#import "MBPayOrderIDCache.h"
#import "MBPayChecker.h"
#import "MBLogger.h"
#import "MBAppStorePayLog.h"
#import "IBHTTPClient.h"
#import "MBJailbroken.h"

NSString * const kVerifyReceiptUrl = @"kApplePayVerifyReceiptUrl";

static const NSInteger maxRetryCount = 3;

@interface MBApplePayModel ()<RMStoreObserver>

@property (nonatomic, copy)   NSString *uid;
@property (nonatomic, copy)   NSString *currentOrderId;
@property (nonatomic, strong) MBPayProduct *product;
@property (nonatomic, strong) NSMutableArray *paymentCheckArr;
@property (nonatomic, strong) NSDictionary *orderBusDic;
@property (nonatomic, assign) BOOL paying;

@end

@implementation MBApplePayModel

#pragma mark - life circle

- (instancetype)init
{
    if (self = [super init]) {
        self.paymentCheckArr = [NSMutableArray array];
        [[RMStore defaultStore] addStoreObserver:self];
    }
    return self;
}

- (void)dealloc
{
    [[RMStore defaultStore] removeStoreObserver:self];
}

#pragma mark - public

- (void)prepareAppleProductList:(NSArray<MBPayProduct *> *)products
{
    NSMutableSet *set = [NSMutableSet set];
    
    for (MBPayProduct *product in products) {
        NSString *appleProductId = product.productId;
        [set addObject:appleProductId];
    }
    
    [[RMStore defaultStore] requestProducts:set
                                    success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        if (invalidProductIdentifiers.count > 0) {
            MBLogI(@"#apple.pay# name:prepare invalidProductId:%@", invalidProductIdentifiers);
        }
    } failure:^(NSError *error) {
        MBLogI(@"#apple.pay# name:prepare error:%@", error.debugDescription);
    }];
}

- (void)createPaymentWithProduct:(MBPayRequest *)request
{
    __weak typeof(self) weakSelf = self;
    
    NSString *pid = request.product.productId;
    BOOL hasOneOrder = [MBPayOrderIDCache hasOneOrderWithProductId:pid uid:request.uid];
    // 检查用户权限
    if ([RMStore canMakePayments]) {
        [self checkJailbroken:^(BOOL jailbroken) {
            if (jailbroken) {
                [weakSelf dealWithError:MBPAYERROR_JAILBROKEN code:IBURLErrorUnknown msg:nil];
            } else {
                if ( weakSelf.paying == YES || hasOneOrder) {
                    [weakSelf dealWithError:MBPAYERROR_PAYING code:IBURLErrorUnknown msg:nil];
                } else {
                    [weakSelf requestServiceForCreatePayment:request];
                }
            }
        }];
    } else {
        [weakSelf dealWithError:MBPAYERROR_NOPERMISSION code:IBURLErrorUnknown msg:nil];
    }
}

- (void)checkCachedApplePay
{
    NSArray *cachedArr = [MBPayChecker ordersFromLocal];
    
    if (cachedArr != nil || [cachedArr isKindOfClass:[NSArray class]]) {
        __weak typeof(self) weakSelf = self;
        
        for (NSDictionary *tmpDic in cachedArr) {
            if (!kIsEmptyDict(tmpDic)) {
                MBPayChecker *pay = [[MBPayChecker alloc] init];

                [weakSelf.paymentCheckArr addObject:pay];
                
                pay.deleteOrderBlock = ^(id<MBPayCheckerProtocol> checker)
                {
                    [weakSelf.paymentCheckArr removeObject:checker];
                };
                [pay checkCachedReceiptWithDic:tmpDic];
            }
        }
    }
}

- (void)restoreApplePay
{
    [[RMStore defaultStore] restoreTransactions];
}

- (void)stopRetry
{
    if (!_paymentCheckArr) {
        return;
    }
    @synchronized (_paymentCheckArr) {
        for (id<MBPayCheckerProtocol> checker in _paymentCheckArr) {
            if (checker) {
                [checker stopRetry];
            }
        }
        _paymentCheckArr = [NSMutableArray array];
    }
}

- (void)checkLocalSubscribeOrder
{
    NSArray *items = [MBPayOrderIDCache allSubscribeOrders];
    MBPayOrderItem *item = [items firstObject];
    if (item) {
        [MBPayChecker checkLocalSubscribeOrder:item];
    }
}

- (void)requestServiceForCreatePayment:(MBPayRequest *)request
{
    self.paying  = YES;
    self.uid     = request.uid;
    self.product = request.product;
    
    NSString *url = request.url;
    
    __weak typeof(self) weakSelf = self;
    
    [IBHTTPManager POST:url params:nil body:request.params completion:^(IBURLErrorCode errorCode, IBURLResponse *response) {
        NSString *orderstr = @"";
        NSString *errMsg = response.message;
        
        if (errorCode == IBURLErrorSuccess) {
            orderstr = [response.dict valueForKey:@"order_id"];
            weakSelf.orderBusDic = response.dict;
        }
        
        if (orderstr.length > 0) {
            [weakSelf requestAppleProductInfo:orderstr product:request.product];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(orderCreated:)]) {
                    [weakSelf.delegate orderCreated:orderstr];
                }
            });
        } else {
            weakSelf.paying = NO;
            [weakSelf dealWithError:MBPAYERROR_CREATEFAIL code:errorCode msg:errMsg];
        }
        
        [MBAppStorePayLog trackCreateWithProductId:request.product.productId order:orderstr money:request.product.money errCode:errorCode errMsg:errMsg];
    }];
}

- (void)requestAppleProductInfo:(NSString *)orderid product:(MBPayProduct *)mbproduct
{
    _currentOrderId = orderid;
    
    __weak typeof(self) weakSelf = self;
    
    NSSet *idSet = [NSSet setWithObject:mbproduct.productId];
    
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:mbproduct.productId];
    
    if (product != nil && [product isKindOfClass:[SKProduct class]]) {
        [weakSelf startApplePayWithProduct:product orderid:orderid product:mbproduct];
    } else {
        [self retryRequestProducts:idSet orderid:orderid retryCount:maxRetryCount product:mbproduct];
    }
}

- (void)startApplePayWithProduct:(SKProduct *)product orderid:(NSString *)orderid product:(MBPayProduct *)mbproduct
{
    MBPayOrderItem *item = [[MBPayOrderItem alloc] init];
    item.uid = self.uid;
    item.orderId = orderid;
    item.productType = mbproduct.productType;
    item.productId = product.productIdentifier;
    
    [MBPayOrderIDCache addOrder:item];
    
    NSString *userIdentifier = [NSString stringWithFormat:@"%@__%@",item.uid,item.orderId];
    
    [[RMStore defaultStore] addPayment:mbproduct.productId
                                  user:userIdentifier
                           requestData:nil
                               success:nil
                               failure:nil];
    
    [MBAppStorePayLog trackStartPayWithProductId:product.productIdentifier order:orderid];
}

- (void)retryRequestProducts:(NSSet*)idSet orderid:(NSString *)orderid retryCount:(NSInteger)retryCount product:(MBPayProduct *)mbproduct {
    __weak typeof(self) weakSelf = self;
    __block NSInteger retryNum = retryCount;
    [[RMStore defaultStore] requestProducts:idSet success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([products count] > 0) {
            for (SKProduct *product in products) {
                [strongSelf startApplePayWithProduct:product orderid:orderid product:mbproduct];
            }
        } else {
            strongSelf.paying = NO;
            [strongSelf dealWithError:MBPAYERROR_NOPRODUCT code:IBURLErrorUnknown msg:nil];
            [MBAppStorePayLog trackRequestFailedWithProductId:mbproduct.productId order:orderid errMsg:@""];
        }
        MBLogI(@"#apple.pay# name:requestProducts invalidProductId:%@", invalidProductIdentifiers);
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (retryNum > 0) {
            retryNum--;
            [strongSelf retryRequestProducts:idSet orderid:orderid retryCount:retryNum product:mbproduct];
        } else {
            strongSelf.paying = NO;
            [MBAppStorePayLog trackRequestFailedWithProductId:mbproduct.productId order:orderid errMsg:error.localizedDescription];
            [strongSelf dealWithError:MBPAYERROR_NOPRODUCT code:error.code msg:error.localizedDescription];
        }
        MBLogI(@"#apple.pay# name:requestProducts error:%@", error);
    }];
}

#pragma mark - RMStoreObserver

- (void)dealWithApplePaySuccessWithTransaction:(SKPaymentTransaction *)transaction
{
    __weak typeof(self) weakSelf = self;
    
    self.paying = NO;
    
    NSString *orderUid;
    NSString *orderid;
    NSArray *items = [MBPayOrderIDCache ordersWithProductId:transaction.payment.productIdentifier];
    
    MBPayOrderItem *item = [items firstObject];
    
    // 沙盒环境，平级订阅 1个月升3个月。先回调1个月成功，后回调3个月的失败，过滤掉此种case的成功事件。
    if (item && item.productType == MBPayProductType_AutoRenewSubscription) {
        if (![item.productId isEqualToString:transaction.payment.productIdentifier]) {
            return;
        }
    }
    
    item = [items firstObject];
    
    NSString *userName = transaction.payment.applicationUsername;
    if (userName) {
        NSArray *userNameArr = [userName componentsSeparatedByString:@"__"];
        orderUid = userNameArr.firstObject;
        orderid = userNameArr.lastObject;
    }else {
        orderid = item.orderId;
        orderUid = item.uid;
    }
    
    if (kIsEmptyString(orderid)) {
        orderid = _currentOrderId;
    }
    
    [MBPayOrderIDCache deleteOrder:item];
        
    item.transactionIdentifier = transaction.transactionIdentifier;
    
    if (item.productType == MBPayProductType_AutoRenewSubscription) {
        item.originTransationId = [self originalTransactionIdentifier:transaction];
        [MBPayOrderIDCache saveSubScribeOrder:item];
    }
    
    if (!self.product) {
        self.product = [[MBPayProduct alloc] init];
    }
    
    if (kIsEmptyString(self.product.productId)) {
        self.product.productId = transaction.payment.productIdentifier;
    }
    
    MBPayChecker *orderCheck = [[MBPayChecker alloc] init];
    
    orderCheck.product = self.product;
    orderCheck.checkErrorBlock = ^(MBPAYERROR type)
    {
        [weakSelf dealWithError:type code:IBURLErrorUnknown msg:nil];
    };
    
    orderCheck.checkSuccessBlock = ^(NSString *orderId)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(paymentCompletion:orderBusDic:orderItem:)])
            {
                [weakSelf.delegate paymentCompletion:YES orderBusDic:weakSelf.orderBusDic orderItem:item];
            }
        });
    };
    
    orderCheck.deleteOrderBlock = ^(id<MBPayCheckerProtocol> checker)
    {
        [weakSelf.paymentCheckArr removeObject:checker];
    };
    
    [orderCheck checkOrderIdWithServer:transaction orderId:orderid uid:orderUid orderItem:item];
    
    [self.paymentCheckArr addObject:orderCheck];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(applePayResult:isSuccess:)]) {
            [self.delegate applePayResult:item isSuccess:YES];
        }
    });
    
    [MBAppStorePayLog trackIAPWithProductId:transaction.payment.productIdentifier order:orderid transactionId:transaction.transactionIdentifier errCode:0 errMsg:@"成功"];
}

- (void)dealWithApplePayFailureWithTransaction:(SKPaymentTransaction *)transaction
{
    self.paying = NO;
    
    NSString *userName = transaction.payment.applicationUsername;
    
    NSString *uid;
    NSString *orderid;
    
    NSArray *items = [MBPayOrderIDCache ordersWithProductId:transaction.payment.productIdentifier];
    if (kIsEmptyArray(items)) {
        items = [MBPayOrderIDCache subscribeOrdersWithProductId:transaction.payment.productIdentifier];
    }
    MBPayOrderItem *item = [items firstObject];
    
    if (userName) {
        NSArray *userNameArr = [userName componentsSeparatedByString:@"__"];
        uid = userNameArr.firstObject;
        orderid = userNameArr.lastObject;
    } else {
        orderid = item.orderId;
        uid = item.uid;
    }
    
    if (kIsEmptyString(orderid)) {
        orderid = _currentOrderId;
    }
    
    NSInteger errCode = transaction.error.code;
    NSString *errMsg = transaction.error.localizedDescription;
    
    errCode = errCode == SKErrorUnknown ? -1 : errCode;
    
    if (errCode == SKErrorPaymentCancelled || errCode == -2) {
        [self dealWithError:MBPAYERROR_USERCANCLE code:IBURLErrorUnknown msg:nil];
        [MBAppStorePayLog trackUserCancelWithProductId:transaction.payment.productIdentifier order:orderid];
    } else {
        [self dealWithError:MBPAYERROR_APPLECONNECTFAIL code:IBURLErrorUnknown msg:nil];
        [MBAppStorePayLog trackIAPWithProductId:transaction.payment.productIdentifier order:orderid transactionId:transaction.transactionIdentifier errCode:errCode errMsg:errMsg];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(applePayResult:isSuccess:)]) {
            [self.delegate applePayResult:item isSuccess:NO];
        }
    });
}

- (void)storePaymentTransactionFinished:(NSNotification *)notification
{
    SKPaymentTransaction *transaction = [notification rm_transaction];
    if (transaction.transactionState != SKPaymentTransactionStateRestored) {
        [self dealWithApplePaySuccessWithTransaction:transaction];
    }
}

- (void)storePaymentTransactionFailed:(NSNotification *)notification
{
    SKPaymentTransaction *transaction = [notification rm_transaction];
    if (transaction.transactionState != SKPaymentTransactionStateRestored) {
        [self dealWithApplePayFailureWithTransaction:transaction];
    }
}

- (void)storePaymentTransactionDeferred:(NSNotification *)notification
{
    SKPaymentTransaction *transaction = [notification rm_transaction];
    MBLogI(@"#apple.pay# name:transaction.deferred productId:%@", transaction.payment.productIdentifier);
}

- (void)storeRestoreTransactionsFailed:(NSNotification *)notification
{
    NSError *error = [notification rm_storeError];
    MBLogI(@"#apple.pay# name:restore.error value:%@", error);
}

- (void)storeRestoreTransactionsFinished:(NSNotification *)notification
{
    // 获取恢复购买数据
    NSMutableArray *transations = [notification rm_transactions].mutableCopy;
    MBLogI(@"#apple.pay# name:restore.finish count:%ld", transations.count);
    // 日期降序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"transactionDate" ascending:NO];
    [transations sortUsingDescriptors:@[sort]];
    
    // 找出不同原始交易号的交易
    NSMutableDictionary *transactionDict = @{}.mutableCopy;
    for (SKPaymentTransaction *transaction in transations) {
        NSString *transactionId = [self originalTransactionIdentifier:transaction];
        if (![transactionDict.allKeys containsObject:transactionId]) {
            [transactionDict setObject:transaction forKey:transactionId];
        }  else {
            MBLogI(@"#apple.pay# name:restore.finish.filter productId:%@", transaction.payment.productIdentifier);
        }
    }
    
    // 验证交易票据
    for (SKPaymentTransaction *transaction in transactionDict.allValues) {
        MBLogI(@"#apple.pay# name:restore.finish.result productId:%@", transaction.payment.productIdentifier);
        [self dealWithApplePaySuccessWithTransaction:transaction];
    }
}

#pragma mark - private

- (NSString *)originalTransactionIdentifier:(SKPaymentTransaction *)transaction
{
    NSString *transactionId = transaction.originalTransaction.transactionIdentifier;
    if (kIsEmptyString(transactionId)) {
        transactionId = transaction.transactionIdentifier;
    }
    return transactionId;
}

- (void)checkJailbroken:(void(^)(BOOL jailbroken))complete
{
    [MBJailbroken checkJailbroken:^(BOOL jailbroken, NSString * _Nonnull msg) {
        MBLogI(@"#apple.pay# name:jailbroken %@", msg);
        if (complete) {
            complete(jailbroken);
        }
    }];
}

- (void)dealWithError:(MBPAYERROR)error code:(NSInteger)code msg:(NSString *)msg
{
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
        case MBPAYERROR_GOLDNOTARRIVE:
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
        if (self.delegate && [self.delegate respondsToSelector:@selector(paymentFailWithType:code:errMsg:)]) {
            [self.delegate paymentFailWithType:error code:code errMsg:msg];
        }
    });
}

@end
