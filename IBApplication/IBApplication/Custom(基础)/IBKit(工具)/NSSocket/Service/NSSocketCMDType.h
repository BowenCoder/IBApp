//
//  NSSocketCMDType.h
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#ifndef NSSocketCMDType_h
#define NSSocketCMDType_h

/**
 在这里书写与服务端约定的协议号...
 */
typedef NS_ENUM(NSUInteger, NSSocketMsgType) {
    
    NSSocket_Msg_Heartbeat                    = 1000, //客户端响应ping
    NSSocket_Msg_HostHeartbeat                = 1001, //主机响应ping
    
    NSSocket_Msg_NoticeReminder               = 1003, //提示
    NSSocket_Msg_Auth                         = 2000, //鉴权
    NSSocket_Msg_HostAuth                     = 2001, //主机鉴权
};

#endif /* NSSocketCMDType_h */
