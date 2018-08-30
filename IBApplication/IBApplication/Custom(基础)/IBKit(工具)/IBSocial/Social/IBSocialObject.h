//
//  IBSocialObject.h
//  IBApplication
//
//  Created by Bowen on 2018/8/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IBSocialPlatformType) {
    IBSocialPlatformUnkown,          //未知
    IBSocialPlatformQQ,              //QQ
    IBSocialPlatformSina,            //新浪
    IBSocialPlatformWechat,          //微信
};

typedef NS_ENUM(NSInteger, IBSharePlatformType) {
    IBSharePlatformUnkown,          //未知
    IBSharePlatformQQSession,       //QQ聊天界面
    IBSharePlatformQZone,           //QQ空间
    IBSharePlatformSina,            //新浪
    IBSharePlatformWechatSession,   //微信聊天
    IBSharePlatformWechatTimeLine,  //微信朋友圈
    IBSharePlatformWechatFavorite,  //微信收藏
};

@interface IBShareObject : NSObject

@property (nonatomic, assign) IBSharePlatformType platformType;

/**
 分享文本(例如分享纯文本就传这个)
 */
@property (nonatomic, copy) NSString *text;

/**
 分享内容标题
 */
@property (nonatomic, copy) NSString *title;

/**
 分享内容描述
 */
@property (nonatomic, copy) NSString *describe;

/**
 分享目标图片
 */
@property (nonatomic, strong) UIImage *image;

/**
 分享预览图(微信中不得超过32K)
 */
@property (nonatomic, strong) UIImage *previewImage;

/**
 分享目标链接(字符串,统一下就不提供NSURL类型的了)
 */
@property (nonatomic, copy) NSString *urlString;

/**
 分享目标链接的预览图链接地址(字符串,统一下就不提供NSURL类型的了)
 */
@property (nonatomic, copy) NSString *previewUrlString;

@end

@interface IBSocialResponse : NSObject

@property (nonatomic, copy) NSString  *uid;         //唯一id
@property (nonatomic, copy) NSString  *openid;      //openid
@property (nonatomic, copy) NSString  *unionId;     //联合id
@property (nonatomic, copy) NSDate    *expiration;  //过期时间
@property (nonatomic, copy) NSString  *accessToken; //访问token
@property (nonatomic, copy) NSString  *refreshToken; //刷新token

/**
 * 第三方原始数据
 */
@property (nonatomic, strong) id  originalResponse;

/**
 第三方平台昵称
 */
@property (nonatomic, copy) NSString  *name;

/**
 第三方平台头像地址
 */
@property (nonatomic, copy) NSString  *iconurl;

/**
 性别
 */
@property (nonatomic, copy) NSString  *gender;

/**
 扩展字段
 */
@property (nonatomic, strong) NSDictionary *extDic;

@end





