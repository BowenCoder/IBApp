//
//  MBPayManager.m
//  MBApplePay
//
//  Created by Bowen on 2019/11/5.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import "MBPayManager.h"
#import "MBApplePayModel.h"

@interface MBPayManager ()<MBPayDelegate>

@property (nonatomic, strong) MBApplePayModel *applePayModel;

@end

@implementation MBPayManager

+ (instancetype)sharedInstance
{
    static MBPayManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[MBPayManager alloc] init];
        }
    });
    return manager;
}

- (void)prepareAppleProductList:(NSArray<MBPayProduct *> *)products
{
    [self.applePayModel prepareAppleProductList:products];
}

- (void)createPaymentWithProduct:(MBPayRequest *)request payDelegate:(id<MBPayDelegate>)delegate
{
    self.applePayModel.delegate = delegate;
    [self.applePayModel createPaymentWithProduct:request];
}

- (void)stopRetry
{
    [self.applePayModel stopRetry];
}

- (void)restoreIAP
{
    [self.applePayModel restoreApplePay];
}

- (void)checkUnFinishedOrder
{
    [self.applePayModel checkUnFinishedOrder];
}

#pragma mark - getter

- (MBApplePayModel *)applePayModel
{
    if (!_applePayModel) {
        _applePayModel = [[MBApplePayModel alloc] init];
    }
    return _applePayModel;
}

@end
