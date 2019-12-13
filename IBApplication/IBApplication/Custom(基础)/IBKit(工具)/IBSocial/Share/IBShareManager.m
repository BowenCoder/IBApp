//
//  IBShareManager.m
//  IBApplication
//
//  Created by Bowen on 2018/8/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBShareManager.h"
#import "IBMacros.h"
#import "UIMacros.h"

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

- (void)shareImage:(IBShareObject *)model success:(IBSuccessBlock)success failure:(IBFailureBlock)failure {
    if (model.platformType == IBSharePlatformUnkown) {
        NSError *error = [NSError errorWithDomain:@"入参错误，请填写平台类型" code:-1000 userInfo:nil];
        failure(error);
        return;
    }
    self.successBlock = success;
    self.failureBlock = failure;
    
    switch (model.platformType) {
        case IBSharePlatformQQSession:
            [self _shareImageToQQSession:model];
            break;
        case IBSharePlatformQZone:
            [self _shareImageToQZone:model];
            break;
        case IBSharePlatformSina:
            [self _shareImageToSina:model];
            break;
        case IBSharePlatformWechatSession:
        case IBSharePlatformWechatTimeLine:
        case IBSharePlatformWechatFavorite:
            [self _shareImageToWechat:model];
            break;
        default:
            break;
    }
    
}

- (void)shareLink:(IBShareObject *)model success:(IBSuccessBlock)success failure:(IBFailureBlock)failure {
    if (model.platformType == IBSharePlatformUnkown) {
        NSError *error = [NSError errorWithDomain:@"入参错误，请填写平台类型" code:-1000 userInfo:nil];
        failure(error);
        return;
    }
    self.successBlock = success;
    self.failureBlock = failure;
    
    switch (model.platformType) {
        case IBSharePlatformQQSession:
            [self _shareLinkToQQSession:model];
            break;
        case IBSharePlatformQZone:
            [self _shareLinkToQZone:model];
            break;
        case IBSharePlatformSina:
            [self _shareLinkToSina:model];
            break;
        case IBSharePlatformWechatSession:
        case IBSharePlatformWechatTimeLine:
        case IBSharePlatformWechatFavorite:
            [self _shareLinkToWechat:model];
            break;
        default:
            break;
    }
}

#pragma mark - 分享图片
- (void)_shareImageToQQSession:(IBShareObject *)model {
    
    if(!kIsEmptyObject(model.image)) {
        QQApiImageObject *imageObject = [QQApiImageObject objectWithData:UIImagePNGRepresentation(model.image) previewImageData:UIImagePNGRepresentation(model.previewImage) title:model.title description:model.describe];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imageObject];
        [QQApiInterface sendReq:req];
    } else {
        NSError *error = [NSError errorWithDomain:@"入参错误，分享图片缺失" code:-1000 userInfo:nil];
        self.failureBlock ? self.failureBlock(error) : nil;
        [self clearData];
    }
}

- (void)_shareImageToQZone:(IBShareObject *)model {
    
    if(!kIsEmptyObject(model.image)) {
        QQApiImageArrayForQZoneObject *imageObj = [QQApiImageArrayForQZoneObject objectWithimageDataArray:@[UIImagePNGRepresentation(model.image)] title:model.title extMap:nil];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imageObj];
        [QQApiInterface SendReqToQZone:req];
    } else {
        NSError *error = [NSError errorWithDomain:@"入参错误，分享图片缺失" code:-1000 userInfo:nil];
        self.failureBlock ? self.failureBlock(error) : nil;
        [self clearData];

    }
}

- (void)_shareImageToSina:(IBShareObject *)model {
    if(!kIsEmptyObject(model.image)) {
        WBMessageObject *message = [WBMessageObject message];
        message.text = model.text;
        WBImageObject *imageObject = [WBImageObject object];
        imageObject.imageData = UIImagePNGRepresentation(model.image);
        message.imageObject = imageObject;
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
        [WeiboSDK sendRequest:request];
    } else {
        NSError *error = [NSError errorWithDomain:@"入参错误，分享链接缺失" code:-1000 userInfo:nil];
        self.failureBlock ? self.failureBlock(error) : nil;
        [self clearData];
    }
}

- (void)_shareImageToWechat:(IBShareObject *)model {
    if(!kIsEmptyObject(model.image)) {
        WXMediaMessage *message = [WXMediaMessage message];
        if(!kIsEmptyObject(model.previewImage)) {
            // model.previewImage不得超过32K
            [message setThumbImage:model.previewImage];
        }
        WXImageObject *imageObject = [WXImageObject object];
        imageObject.imageData = UIImagePNGRepresentation(model.image);
        message.mediaObject = imageObject;
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.message = message;
        req.bText = NO;
        if (model.platformType == IBSharePlatformWechatSession) {
            req.scene = WXSceneSession;
        }
        if (model.platformType == IBSharePlatformWechatTimeLine) {
            req.scene = WXSceneTimeline;
        }
        if (model.platformType == IBSharePlatformWechatFavorite) {
            req.scene = WXSceneFavorite;
        }
        [WXApi sendReq:req];
    } else {
        NSError *error = [NSError errorWithDomain:@"入参错误，分享图片缺失" code:-1000 userInfo:nil];
        self.failureBlock ? self.failureBlock(error) : nil;
        [self clearData];
    }
}

#pragma mark - 分享链接

- (void)_shareLinkToQQSession:(IBShareObject *)model {
    if(!kIsEmptyObject(model.urlString)) {
        QQApiNewsObject *newsObject = nil;
        if(!kIsEmptyObject(model.previewUrlString)) {
            newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:model.urlString] title:model.title description:model.describe previewImageURL:[NSURL URLWithString:model.previewUrlString]];
        } else {
            if (!kIsEmptyObject(model.previewImage)) {
                newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:model.urlString] title:model.title description:model.describe previewImageData:UIImagePNGRepresentation(model.previewImage)];
            } else {
                newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:model.urlString] title:model.title description:model.describe previewImageURL:nil];
            }
        }
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObject];
        [QQApiInterface sendReq:req];
    } else {
        NSError *error = [NSError errorWithDomain:@"入参错误，分享链接缺失" code:-1000 userInfo:nil];
        self.failureBlock ? self.failureBlock(error) : nil;
        [self clearData];
    }
}

- (void)_shareLinkToQZone:(IBShareObject *)model {
    if(!kIsEmptyObject(model.urlString)) {
        QQApiNewsObject *newsObject = nil;
        if(!kIsEmptyObject(model.previewUrlString)) {
            newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:model.urlString] title:model.title description:model.describe previewImageURL:[NSURL URLWithString:model.previewUrlString]];
        } else {
            if (!kIsEmptyObject(model.previewImage)) {
                newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:model.urlString] title:model.title description:model.describe previewImageData:UIImagePNGRepresentation(model.previewImage)];
            } else {
                newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:model.urlString] title:model.title description:model.describe previewImageURL:nil];
            }
        }
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObject];
        [QQApiInterface SendReqToQZone:req];
    } else {
        NSError *error = [NSError errorWithDomain:@"入参错误，分享链接缺失" code:-1000 userInfo:nil];
        self.failureBlock ? self.failureBlock(error) : nil;
        [self clearData];
    }
}

- (void)_shareLinkToSina:(IBShareObject *)model {
    
    if(!kIsEmptyObject(model.urlString)) {
        WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
        authRequest.redirectURI = @"https://api.weibo.com/oauth2/default.html";
        authRequest.scope = @"all";
        WBMessageObject *message = [WBMessageObject message];
        kIsEmptyObject(model.text) ? (message.text = model.urlString) : (message.text = [NSString stringWithFormat:@"%@ %@",model.text,model.urlString]);
        if(!kIsEmptyObject(model.image)) {
            WBImageObject *imageObject = [WBImageObject object];
            imageObject.imageData = UIImagePNGRepresentation(model.image);
            message.imageObject = imageObject;
        }
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
        [WeiboSDK sendRequest:request];
    } else {
        NSError *error = [NSError errorWithDomain:@"入参错误，分享链接缺失" code:-1000 userInfo:nil];
        self.failureBlock ? self.failureBlock(error) : nil;
        [self clearData];
    }
}

- (void)_shareLinkToWechat:(IBShareObject *)model {
    if(!kIsEmptyObject(model.urlString)) {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = model.title;
        message.description = model.description;
        [message setThumbImage:model.previewImage];
        WXWebpageObject *linkObject = [WXWebpageObject object];
        linkObject.webpageUrl = model.urlString;
        message.mediaObject = linkObject;
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        if (model.platformType == IBSharePlatformWechatSession) {
            req.scene = WXSceneSession;
        }
        if (model.platformType == IBSharePlatformWechatTimeLine) {
            req.scene = WXSceneTimeline;
        }
        if (model.platformType == IBSharePlatformWechatFavorite) {
            req.scene = WXSceneFavorite;
        }
        [WXApi sendReq:req];
    } else {
        NSError *error = [NSError errorWithDomain:@"入参错误，分享链接缺失" code:-1000 userInfo:nil];
        self.failureBlock ? self.failureBlock(error) : nil;
        [self clearData];
    }
}

#pragma mark - IBSocialDelegate

- (void)share:(id)result error:(NSError *)error {
    if (!error && self.successBlock) {
        self.successBlock(result);
    } else {
        self.failureBlock(error);
    }
    [self clearData];
}

- (void)clearData {
    self.successBlock = nil;
    self.failureBlock = nil;
    [IBSocialManager manager].delegate = nil;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
