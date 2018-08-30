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
     *  其他错误
     */
    IBOtherError = -1,
    /**
     *  超时
     */
    IBTimeout = -2,
    /**
     *  http非200错误
     */
    IBHttpError = -3,
    /**
     *  请求参数错误    请求的参数传递错误
     */
    IBArgumentError = 499,
    /**
     *  系统错误    服务内部发生错误
     */
    IBSystemError = 500,
};


#endif /* IBErrorCode_h */
