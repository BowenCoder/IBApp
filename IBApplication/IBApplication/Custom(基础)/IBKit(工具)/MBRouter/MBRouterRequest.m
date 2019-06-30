//
//  MBRouterRequest.m
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBRouterRequest.h"
#import "NSDictionary+Ext.h"
#import "IBHelper.h"
#import "IBEncode.h"
#import "IBMacros.h"

@implementation MBRouterRequest

- (void)setURLString:(NSString *)URLString
{
    _URLString = URLString;
    
    if (kIsEmptyString(URLString)) {
        _pName = nil;
        _scheme = nil;
        _options = nil;
        _sourceApplication = nil;
    } else {
        [self handleURLString:URLString];
    }
}

- (void)handleURLString:(NSString *)URLString
{
    NSURL *url = [NSURL URLWithString:URLString];
    if (url == nil) {
        NSString *urlStr = [IBEncode URLEncode:[URLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        url = [NSURL URLWithString:urlStr];
    }
    
    _scheme = [url scheme];
    _options = [IBHelper dictionaryWithURL:url];
    _pName = [[_options mb_stringForKey:kRouterPageName] lowercaseString];
    _sourceApplication = [_options mb_stringForKey:kRouterSourceApplication];
}

+ (instancetype)requestWithURLString:(NSString *)URLString resultCallback:(MBRouterResultCallback)resultCallback
{
    MBRouterRequest *request = [[MBRouterRequest alloc] init];
    request.URLString = URLString;
    request.resultCallback = resultCallback;
    return request;
}



@end
