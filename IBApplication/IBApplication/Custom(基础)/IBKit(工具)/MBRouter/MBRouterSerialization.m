//
//  MBRouterSerialization.m
//  IBApplication
//
//  Created by Bowen on 2019/12/11.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBRouterSerialization.h"
#import "NSDictionary+Ext.h"
#import "IBHelper.h"
#import "YYModel.h"

@implementation MBRouterSerialization

+ (NSString *)routerLinkFormat:(NSString *)pName
{
    return [NSString stringWithFormat:@"appName://pname=%@", pName];
}

+ (NSString *)routerLinkFormat:(NSString *)pName model:(id)model
{
    NSString *params = [model yy_modelToJSONString];
    NSString *link = [self routerLinkFormat:pName];
    if (params) {
        return [NSString stringWithFormat:@"%@&inner_params=%@", link, params];
    }
    return link;
}

+ (id)modelWithOptions:(NSDictionary *)options model:(Class)cls
{
    NSString *params = [options mb_stringForKey:@"inner_params"];
    NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [cls yy_modelWithDictionary:dict];
}

+ (NSString *)routerLinkFormat:(NSString *)pName params:(NSDictionary *)params
{
    NSString *link = [self routerLinkFormat:pName];
    NSString *query = [IBHelper URLQueryString:params];
    return [NSString stringWithFormat:@"%@%@", link, query];
}

@end
