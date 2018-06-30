//
//  NSSocketCMDType.h
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#ifndef NSSocketCMDType_h
#define NSSocketCMDType_h

/** 在这里书写与服务端约定的协议号... */
typedef NS_ENUM(NSInteger, NSSocketMsgType) {
    NSSocket_Msg_Heartbeat                    = 1000, //客户端响应ping
    NSSocket_Msg_HostHeartbeat                = 1001, //主机响应ping
    NSSocket_Msg_Common                       = 1002, //普通消息
    NSSocket_Msg_NoticeReminder               = 1003, //提示
    NSSocket_Msg_Auth                         = 2000, //鉴权
    NSSocket_Msg_HostAuth                     = 2001, //主机鉴权
};


/** 错误 */
typedef NS_ENUM(NSInteger, NSSocketError) {
    NSSocketErrorTimeout  = 0, //请求超时
    NSSocketErrorParam    = 1, //入参错误
    NSSocketErrorRequest  = 2, //请求错误
    NSSocketErrorToken    = 3, //token失效
    NSSocketErrorNetwork  = 4, //网络断开
    NSSocketErrorJson     = 5, //json解析错误
    NSSocketErrorUserLoss = 6, //用户状态丢失
    NSSocketErrorNoResult = 7, //查询结果为空
    NSSocketErrorUnknown  = 8 //系统存在异常
};


#endif /* NSSocketCMDType_h */
