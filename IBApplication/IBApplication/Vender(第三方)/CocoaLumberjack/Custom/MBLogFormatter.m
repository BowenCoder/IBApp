//
//  MBLogFormatter.m
//  IBApplication
//
//  Created by Bowen on 2019/5/14.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBLogFormatter.h"

@interface MBLogFormatter ()

@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation MBLogFormatter

- (NSString*)formatLogMessage:(DDLogMessage *)logMessage
{
    
    NSString *dateAndTime = [self.formatter stringFromDate:(logMessage.timestamp)];
    
    NSString *logLevel = nil;
    switch (logMessage.flag) {
        case DDLogFlagError     : logLevel = @"E"; break;
        case DDLogFlagWarning   : logLevel = @"W"; break;
        case DDLogFlagInfo      : logLevel = @"I"; break;
        case DDLogFlagDebug     : logLevel = @"D"; break;
        case DDLogFlagVerbose   : logLevel = @"V"; break;
        default                 : logLevel = @"?"; break;
    }
    
    logLevel = [NSString stringWithFormat:@"[%@]", logLevel];
    
    NSString *formattedLog = [NSString stringWithFormat:@"%@\t %@\t %d:%ld\t %@\t %@\t %@(%lu)",
                              dateAndTime,
                              logLevel,
                              [[NSProcessInfo processInfo] processIdentifier],
                              logMessage.threadSequenceNumber,
                              logMessage.message,
                              logMessage.function,
                              logMessage.file.lastPathComponent,
                              (unsigned long)logMessage.line];
    
    return formattedLog;
}

- (NSDateFormatter *)formatter {
    if(!_formatter){
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [_formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS"];
    }
    return _formatter;
}


@end

@interface MBLogDebugFormatter ()

@property (nonatomic, strong) NSDateFormatter *formatter;

@end


@implementation MBLogDebugFormatter

- (NSString*)formatLogMessage:(DDLogMessage *)logMessage
{
    
    NSString *dateAndTime = [self.formatter stringFromDate:(logMessage.timestamp)];
    
    NSString *logLevel = nil;
    switch (logMessage.flag) {
        case DDLogFlagError     : logLevel = @"E"; break;
        case DDLogFlagWarning   : logLevel = @"W"; break;
        case DDLogFlagInfo      : logLevel = @"I"; break;
        case DDLogFlagDebug     : logLevel = @"D"; break;
        case DDLogFlagVerbose   : logLevel = @"V"; break;
        default                 : logLevel = @"?"; break;
    }
    
    logLevel = [NSString stringWithFormat:@"[%@]", logLevel];
    
    NSString *formattedLog = [NSString stringWithFormat:@"%@ %@ %d:%ld 🍎 %@(%lu) ⚽️ %@ 🖍\n %@",
                              dateAndTime,
                              logLevel,
                              [[NSProcessInfo processInfo] processIdentifier],
                              logMessage.threadSequenceNumber,
                              logMessage.file.lastPathComponent,
                              (unsigned long)logMessage.line,
                              logMessage.function,
                              logMessage.message];
    
    return formattedLog;
}

- (NSDateFormatter *)formatter {
    if(!_formatter){
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [_formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS"];
    }
    return _formatter;
}

@end

