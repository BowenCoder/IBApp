//
//  MBSocketCMDType.h
//  IBApplication
//
//  Created by Bowen on 2020/6/9.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#ifndef MBSocketCMDType_h
#define MBSocketCMDType_h

@class MBSocketReceivePacket;

typedef void (^MBSocketRspCallback)(MBSocketReceivePacket *packet);

static const NSInteger kSocketVersion = 0x0001;

static const NSInteger kSocketMessageHeaderLength           = 20;        // 20Byte
static const NSInteger kSocketMessageMaxBodyLength          = 20 * 1024; // 20KB
static const NSInteger kSocketMessageMaxExtraHeaderLength   = 10 * 1024; // 10KB

static const NSInteger kSocketMessageHeaderTag              = 10001;
static const NSInteger kSocketMessageExtraHeaderTag         = 10002;
static const NSInteger kSocketMessageBodyTag                = 10003;
static const NSInteger kSocketMessageWriteTag               = 10004;

/** 与服务端约定的协议号... */
typedef NS_ENUM(NSInteger, MBSocketMessageType) {
    MBSocketMessageHeartbeat                    = 1000, //心跳的消息
    MBSocketMessageCommon                       = 1001, //通用的消息
    MBSocketMessageNotice                       = 1002, //提示的消息
    MBSocketMessageHandshake                    = 1003, //握手的消息
    MBSocketMessageLogin                        = 1004, //登录的消息
    MBSocketMessageSubscribe                    = 1005, //订阅的消息
    MBSocketMessageService                      = 2000, //服务主动下发的消息
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
    MBSocketErrorNeedLogin        = 2008,   //需要登录
    MBSocketErrorKicked           = 2009,   //用户被踢出
    MBSocketErrorDisconnected     = 2010,   //断开连接
};


#endif /* MBSocketCMDType_h */
