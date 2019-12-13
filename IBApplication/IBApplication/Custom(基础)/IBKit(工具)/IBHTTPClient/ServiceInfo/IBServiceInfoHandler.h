//
//  IBServiceInfoHandler.h
//  IBApplication
//
//  Created by Bowen on 2019/7/1.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 注意点：
 1）在willFinishLaunching初始化
 2）后期ServiceInfo数据大需异步读写文件
 */

NS_ASSUME_NONNULL_BEGIN

@interface IBServiceInfoHandler : NSObject

- (void)loadServiceInfo;

@end

NS_ASSUME_NONNULL_END

