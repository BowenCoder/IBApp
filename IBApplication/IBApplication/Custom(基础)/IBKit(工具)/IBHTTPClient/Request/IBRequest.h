//
//  IBRequest.h
//  IBApplication
//
//  Created by BowenCoder on 2019/7/7.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBRequestProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface IBRequest : NSObject <IBRequestProtocol>

@end

@interface IBGetRequest : IBRequest

@end

@interface IBPostJsonRequest : IBRequest <IBPostJsonRequestProtocol>

@end

@interface IBPostBinaryRequest : IBRequest <IBPostBinaryRequestProtocol>

@end




NS_ASSUME_NONNULL_END
