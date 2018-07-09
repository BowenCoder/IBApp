//
//  IBModelController.h
//  IBApplication
//
//  Created by Bowen on 2018/7/1.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBController.h"
#import "IBHTTPClient.h"

@interface IBModelController : IBController

- (void)pageLoad:(NSString *)url params:(NSDictionary *)params success:(HTTPClientSuccess)success failure:(HTTPClientError)failure isGet:(BOOL)isGet;

@end
