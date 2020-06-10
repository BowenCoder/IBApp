//
//  MBSocketCMDType.h
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#ifndef MBSocketCMDType_h
#define MBSocketCMDType_h

static const NSInteger kSocketVersion = 0x0001;

static const NSInteger kSocketMessageHeaderLength           = 20;
static const NSInteger kSocketMessageMaxBodyLength          = 20 * 1024;
static const NSInteger kSocketMessageMaxExtraHeaderLength   = 1024;

static const NSInteger kSocketMessageHeaderTag              = 10001;
static const NSInteger kSocketMessageExtraHeaderTag         = 10002;
static const NSInteger kSocketMessageBodyTag                = 10003;
static const NSInteger kSocketMessageWriteTag               = 10004;

/** 与服务端约定的协议号... */
typedef NS_ENUM(NSInteger, MBSocketMessageType) {
    MBSocketMessageHeartbeat                    = 1000, //心跳
    MBSocketMessageCommon                       = 1001, //通用
    MBSocketMessageNotice                       = 1002, //提示
    MBSocketMessageHandshake                    = 1003, //握手
    MBSocketMessageLogin                        = 1004, //登录
};

/** 错误码 */
typedef NS_ENUM(NSInteger, MBSocketErrorCode) {
    MBSocketErrorTimeout          = -1001,  //请求超时
    MBSocketErrorUnknown          = -1,     //未知错误
    MBSocketErrorSuccess          = 0,      //成功
    MBSocketErrorNeedHandshake    = 2003,   //重新握手
    MBSocketErrorNetwork          = 2004,   //网络断开
    MBSocketErrorJsonParse        = 2005,   //json解析错误
    MBSocketErrorRC4KeyExpired    = 2006,   //RC4秘钥过期
    MBSocketErrorRSAPubKeyExpired = 2007,   //RSA公钥过期
    MBSocketErrorKicked           = 2008,   //用户被踢出
};


#endif /* MBSocketCMDType_h */
