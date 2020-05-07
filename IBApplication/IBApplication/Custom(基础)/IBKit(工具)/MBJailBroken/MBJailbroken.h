//
//  GMCheckJailbroken.h
//  IBApplication
//
//  Created by Bowen on 2019/11/27.
//  Copyright © 2019 yu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBJailbroken : NSObject

+ (void)checkJailbroken:(void(^)(BOOL jailbroken, NSString *msg))completion;

@end

NS_ASSUME_NONNULL_END
