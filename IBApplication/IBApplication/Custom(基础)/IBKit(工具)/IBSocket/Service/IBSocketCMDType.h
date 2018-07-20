//
//  IBSocketCMDType.h
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#ifndef IBSocketCMDType_h
#define IBSocketCMDType_h

/** 在这里书写与服务端约定的协议号... */
typedef NS_ENUM(NSInteger, IBSocketMsgType) {
    IBSocket_Msg_Heartbeat                    = 1000, //客户端响应ping
    IBSocket_Msg_HostHeartbeat                = 1001, //主机响应ping
    IBSocket_Msg_Common                       = 1002, //普通消息
    IBSocket_Msg_NoticeReminder               = 1003, //提示
    IBSocket_Msg_Auth                         = 2000, //鉴权
    IBSocket_Msg_HostAuth                     = 2001, //主机鉴权
};


/** 错误 */
typedef NS_ENUM(NSInteger, IBSocketError) {
    IBSocketErrorTimeout  = 0, //请求超时
    IBSocketErrorParam    = 1, //入参错误
    IBSocketErrorRequest  = 2, //请求错误
    IBSocketErrorToken    = 3, //token失效
    IBSocketErrorNetwork  = 4, //网络断开
    IBSocketErrorJson     = 5, //json解析错误
    IBSocketErrorUserLoss = 6, //用户状态丢失
    IBSocketErrorNoResult = 7, //查询结果为空
    IBSocketErrorUnknown  = 8 //系统存在异常
};


#endif /* IBSocketCMDType_h */
