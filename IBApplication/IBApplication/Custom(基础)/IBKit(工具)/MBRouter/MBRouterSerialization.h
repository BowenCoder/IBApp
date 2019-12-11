//
//  MBRouterSerialization.h
//  IBApplication
//
//  Created by Bowen on 2019/12/11.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBRouterSerialization : NSObject

+ (NSString *)routerLinkFormat:(NSString *)pName;

+ (NSString *)routerLinkFormat:(NSString *)pName model:(id)model;

+ (id)modelWithOptions:(NSDictionary *)options model:(Class)cls;

@end

NS_ASSUME_NONNULL_END
