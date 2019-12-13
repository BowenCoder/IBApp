//
//  IBServiceInfoHandler.m
//  IBApplication
//
//  Created by Bowen on 2019/7/1.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBServiceInfoHandler.h"
#import "IBHTTPManager.h"
#import "IBUrlManager.h"
#import "IBNetworkConfig.h"
#import "NSDictionary+Ext.h"
#import "IBFile.h"
#import "MBLogger.h"

@interface IBServiceInfoHandler ()

@property (nonatomic, copy) NSString *enterUrl;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *version;

@end

@implementation IBServiceInfoHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
        [self loadCache];
    }
    return self;
}

- (void)setup
{
    self.filePath = [IBFile filePathInDataDirInLibrary:@"serviceinfo.plist"];
    self.enterUrl = [IBNetworkConfig enterUrl];
}

- (void)loadCache
{
    NSDictionary *serviceInfo;
    if ([IBFile isFileExists:self.filePath]) {
        serviceInfo = [[NSDictionary alloc] initWithContentsOfFile:self.filePath];
    } else {
        serviceInfo = [IBNetworkConfig serviceInfo];
    }
    self.version = [serviceInfo mb_stringForKey:@"version"] ?: @"1.0.0";
    [[IBUrlManager sharedInstance] updateUrlConfig:serviceInfo];
}

- (void)loadServiceInfo
{
    NSDictionary *params = @{@"version": self.version};
    [IBHTTPManager GETRetry:self.enterUrl params:params completion:^(IBURLErrorCode errorCode, IBURLResponse *response) {
        if (errorCode == IBURLErrorSuccess) {
            NSDictionary *dict = [response.dict objectForKey:@"data"];
            NSDictionary *serviceInfo = [[IBUrlManager sharedInstance] updateUrlConfig:dict];
            NSString *version = [serviceInfo mb_stringForKey:@"version"];
            self.version = version;
            [IBFile writeFileAtPath:self.filePath content:serviceInfo error:nil];
        } else {
            if (![self.enterUrl isEqualToString:[IBNetworkConfig backupUrl]]) {
                self.enterUrl = [IBNetworkConfig backupUrl];
                [self loadServiceInfo];
            } else {
                MBLogE(@"#ServiceInfo# url load failed %@", response.message);
            }
        }
    }];
}


@end
