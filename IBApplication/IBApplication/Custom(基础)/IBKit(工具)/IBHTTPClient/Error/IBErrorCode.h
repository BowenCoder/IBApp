//
//  IBErrorCode.h
//  IBApplication
//
//  Created by Bowen on 2018/8/30.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#ifndef IBErrorCode_h
#define IBErrorCode_h

/**
 网络错误参考：NSURLErrorDomain
 网络未发送出去：ErrorCode在NSURLErrorBadServerResponse和NSURLErrorCancelled之间
 */
typedef NS_ENUM(NSInteger, IBURLErrorCode) {
    
    IBURLErrorTimeout = -1001, // 超时
        
    IBURLErrorMethod = -6, // 请求method错误
    
    IBURLErrorParameter = -5, // 参数错误
    
    IBURLErrorAddress = -4, // 地址错误
    
    IBURLErrorDouble = -3, // 重复请求
    
    IBURLErrorBadNet = -2, // 网络错误
    
    IBURLErrorUnknown = -1, // 未知错误
    
    IBURLErrorSuccess = 0, // 成功

    IBURLErrorService = 500, // 服务内部发生错误

    IBURLErrrorSession = 604, // session错误

    IBURLErrorContent = 982, // 内容非法错误
};


#endif /* IBErrorCode_h */
