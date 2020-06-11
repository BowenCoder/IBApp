//
//  MBSocketClient.h
//  IBApplication
//
//  Created by Bowen on 2020/6/10.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBSocketConnectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBSocketClient : NSObject

- (BOOL)isConnected;

- (BOOL)isDisconnected;

- (void)disconnect;

- (void)connectWithModel:(MBSocketConnectionModel *)model;

@end

NS_ASSUME_NONNULL_END
