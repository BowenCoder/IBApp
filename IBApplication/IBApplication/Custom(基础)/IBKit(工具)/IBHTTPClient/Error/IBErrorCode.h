//
//  IBErrorCode.h
//  IBApplication
//
//  Created by Bowen on 2018/8/30.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#ifndef IBErrorCode_h
#define IBErrorCode_h


typedef NS_ENUM(NSInteger, IBErrorCode) {
    /**
     *  成功
     */
    IBSUCCESS = 0,
    /**
     *  未知错误
     */
    IBOtherError = -1,
    /**
     *  超时
     */
    IBTimeout = -2,
    /**
     *  请求链接错误
     */
    IBURLError = -3,
    /**
     *  请求参数错误
     */
    IBArgumentError = 499,
    /**
     *  服务内部发生错误
     */
    IBSystemError = 500,
    /**
     *  权限错误
     */
    IBAuthError = 600,
    /**
     *  session错误
     */
    IBSessionError = 604,
    /**
     *  内容非法：包含敏感词
     */
    IBContentError = 982,

};


#endif /* IBErrorCode_h */
