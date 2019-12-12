//
//  IBServiceInfoModel.h
//  IBApplication
//
//  Created by Bowen on 2019/12/12.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface IBServiceInfoModel : NSObject

- (NSDictionary *)refreshServiceInfo:(NSDictionary *)dict;

- (NSString *)urlFromKey:(NSString *)key;

- (BOOL)switchFromKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
