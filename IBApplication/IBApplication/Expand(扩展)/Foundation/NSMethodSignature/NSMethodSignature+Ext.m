//
//  NSMethodSignature+Ext.m
//  IBApplication
//
//  Created by Bowen on 2020/3/30.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "NSMethodSignature+Ext.h"
#import "IBMacros.h"

@implementation NSMethodSignature (Ext)

+ (NSMethodSignature *)fb_avoidExceptionSignature {
    // https://github.com/facebookarchive/AsyncDisplayKit/pull/1562
    // Unfortunately, in order to get this object to work properly, the use of a method which creates an NSMethodSignature
    // from a C string. -methodSignatureForSelector is called when a compiled definition for the selector cannot be found.
    // This is the place where we have to create our own dud NSMethodSignature. This is necessary because if this method
    // returns nil, a selector not found exception is raised. The string argument to -signatureWithObjCTypes: outlines
    // the return type and arguments to the message. To return a dud NSMethodSignature, pretty much any signature will
    // suffice. Since the -forwardInvocation call will do nothing if the delegate does not respond to the selector,
    // the dud NSMethodSignature simply gets us around the exception.
    return [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
}

- (NSString *)fb_typeString {
    BeginIgnoreClangWarning("-Warc-performSelector-leaks");
    NSString *typeString = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"_%@String", @"type"])];
    EndIgnoreClangWarning;
    return typeString;
}

- (const char *)fb_typeEncoding {
    return self.fb_typeString.UTF8String;
}


@end
