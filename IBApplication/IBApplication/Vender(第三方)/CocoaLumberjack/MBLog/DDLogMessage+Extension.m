//
//  DDLogMessage+Extension.m
//  IBApplication
//
//  Created by Bowen on 2019/5/15.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "DDLogMessage+Extension.h"
#import "NSThread+SequenceNumber.h"
#import <objc/runtime.h>
#import <pthread.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation DDLogMessage (Extension)

- (void)setThreadSequenceNumber:(NSInteger)threadSequenceNumber
{
    objc_setAssociatedObject(self, @selector(threadSequenceNumber), @(threadSequenceNumber), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)threadSequenceNumber
{
    return [objc_getAssociatedObject(self, @selector(threadSequenceNumber)) integerValue];
}

- (instancetype)initWithMessage:(NSString *)message
                          level:(DDLogLevel)level
                           flag:(DDLogFlag)flag
                        context:(NSInteger)context
                           file:(NSString *)file
                       function:(NSString *)function
                           line:(NSUInteger)line
                            tag:(id)tag
                        options:(DDLogMessageOptions)options
                      timestamp:(NSDate *)timestamp
{
    
    if ((self = [super init])) {
        BOOL copyMessage = (options & DDLogMessageDontCopyMessage) == 0;
        _message      = copyMessage ? [message copy] : message;
        _level        = level;
        _flag         = flag;
        _context      = context;
        
        BOOL copyFile = (options & DDLogMessageCopyFile) != 0;
        _file = copyFile ? [file copy] : file;
        
        BOOL copyFunction = (options & DDLogMessageCopyFunction) != 0;
        _function = copyFunction ? [function copy] : function;
        
        _line         = line;
        _tag          = tag;
        _options      = options;
        _timestamp    = timestamp ?: [NSDate new];
        
        __uint64_t tid;
        if (pthread_threadid_np(NULL, &tid) == 0) {
            _threadID = [[NSString alloc] initWithFormat:@"%llu", tid];
        } else {
            _threadID = @"missing threadId";
        }
        _threadName   = NSThread.currentThread.name;
        
        // Get the file name without extension
        _fileName = [_file lastPathComponent];
        NSUInteger dotLocation = [_fileName rangeOfString:@"." options:NSBackwardsSearch].location;
        if (dotLocation != NSNotFound)
        {
            _fileName = [_fileName substringToIndex:dotLocation];
        }
        
        // Try to get the current queue's label
        _queueLabel = [[NSString alloc] initWithFormat:@"%s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)];
        
        self.threadSequenceNumber = [[NSThread currentThread] sequenceNumber];
    }
    return self;
}

- (id)copyWithZone:(NSZone * __attribute__((unused)))zone {
    DDLogMessage *newMessage = [DDLogMessage new];
    
    newMessage->_message = _message;
    newMessage->_level = _level;
    newMessage->_flag = _flag;
    newMessage->_context = _context;
    newMessage->_file = _file;
    newMessage->_fileName = _fileName;
    newMessage->_function = _function;
    newMessage->_line = _line;
    newMessage->_tag = _tag;
    newMessage->_options = _options;
    newMessage->_timestamp = _timestamp;
    newMessage.threadSequenceNumber = self.threadSequenceNumber;
    newMessage->_threadID = _threadID;
    newMessage->_threadName = _threadName;
    newMessage->_queueLabel = _queueLabel;
    
    return newMessage;
}

/*
- (void)callOriginalMethod:(SEL)selector
                   message:(NSString *)message
                     level:(DDLogLevel)level
                      flag:(DDLogFlag)flag
                   context:(NSInteger)context
                      file:(NSString *)file
                  function:(NSString *)function
                      line:(NSUInteger)line
                       tag:(id)tag
                   options:(DDLogMessageOptions)options
                 timestamp:(NSDate *)timestamp {

    unsigned int count;
    unsigned int index = 0;

    //获得指向该类所有方法的指针
    Method *methods = class_copyMethodList([self class], &count);

    for (int i = 0; i < count; i++) {
        //获得该类的一个方法指针
        Method method = methods[i];
        //获取方法
        SEL methodSEL = method_getName(method);
        if (methodSEL == selector) {
            index = i;
        }
    }
    SEL fontSEL = method_getName(methods[index]);
    IMP fontIMP = method_getImplementation(methods[index]);
    ((void (*)(id, SEL, id, DDLogLevel, DDLogFlag, NSInteger, NSString *, NSString *, NSUInteger, id, DDLogMessageOptions, NSDate *))fontIMP)(self, fontSEL, message, level, flag, context, file, function, line, tag, options, timestamp);

    free(methods);
}
*/

@end

#pragma clang diagnostic pop

