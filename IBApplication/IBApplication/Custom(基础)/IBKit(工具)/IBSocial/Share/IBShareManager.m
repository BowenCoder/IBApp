//
//  IBShareManager.m
//  IBApplication
//
//  Created by Bowen on 2018/8/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBShareManager.h"
#import "MBProgressHUD+Ext.h"

@interface IBShareManager () <IBSocialDelegate>

@property (nonatomic, copy) IBSuccessBlock successBlock;
@property (nonatomic, copy) IBFailureBlock failureBlock;

@end

@implementation IBShareManager

+ (instancetype)manager {
    IBShareManager *manager = [[IBShareManager alloc] init];
    [IBSocialManager manager].delegate = manager;
    return manager;
}

- (void)shareToQQ:(IBShareObject *)model success:(IBSuccessBlock)success failure:(IBFailureBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;
    
    SendMessageToQQReq *req;
    if (model.urlString.length == 0) {
        QQApiImageObject *qqImageObject = [QQApiImageObject objectWithData:UIImageJPEGRepresentation(model.image, 1.0) previewImageData:UIImageJPEGRepresentation(model.previewImage, 1.0) title:model.title description:model.describe];
        req = [SendMessageToQQReq reqWithContent:qqImageObject];
    } else {
        QQApiURLObject *qqUrlObject = [QQApiURLObject objectWithURL:[[NSURL alloc] initWithString:model.urlString]
                                                              title:model.urlString
                                                        description:model.describe
                                                   previewImageData:UIImageJPEGRepresentation(model.image, 0.9)
                                                  targetContentType:QQApiURLTargetTypeNews];
        qqUrlObject.shareDestType = ShareDestTypeQQ;
        req = [SendMessageToQQReq reqWithContent:qqUrlObject];
    }
    [QQApiInterface sendReq:req];
}

#pragma mark - IBSocialDelegate

- (void)auth:(id)result error:(NSError *)error {
    if (!error && self.successBlock) {
        self.successBlock(result);
        self.successBlock = nil;
    } else {
        self.failureBlock(error);
        self.failureBlock = nil;
    }
}

- (void)share:(id)result error:(NSError *)error {
    if (!error && self.successBlock) {
        self.successBlock(result);
        self.successBlock = nil;
    } else {
        self.failureBlock(error);
        self.failureBlock = nil;
    }
}

@end
