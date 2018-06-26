//
//  NSEncode.m
//  IBApplication
//
//  Created by Bowen on 2018/6/26.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSEncode.h"
#import <CommonCrypto/CommonDigest.h>

#define FileHashDefaultChunkSizeForReadingData 1024*8 // 8K

@implementation NSEncode

+ (NSString*)md5WithData:(NSData *)data{
    
    if (!data) {
        return nil;//判断sourceString如果为空则直接返回nil。
    }
    //需要MD5变量并且初始化
    CC_MD5_CTX  md5;
    CC_MD5_Init(&md5);
    //开始加密(第一个参数：对md5变量去地址，要为该变量指向的内存空间计算好数据，第二个参数：需要计算的源数据，第三个参数：源数据的长度)
    CC_MD5_Update(&md5, data.bytes, (CC_LONG)data.length);
    //声明一个无符号的字符数组，用来盛放转换好的数据
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //将数据放入result数组
    CC_MD5_Final(result, &md5);
    //将result中的字符拼接为OC语言中的字符串，以便我们使用。
    NSMutableString *resultString = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X",result[i]];
    }
    return [resultString lowercaseString];
}

+ (NSString*)md5WithFile:(NSString*)path {
    
    CFStringRef strRef = (__bridge CFStringRef)path;
    return (__bridge NSString *)FileMD5HashCreateWithPath(strRef,FileHashDefaultChunkSizeForReadingData);
}

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,
                                      size_t chunkSizeForReadingData) {
    
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    
    CC_MD5_CTX hashObject;
    bool hasMoreData = true;
    bool didSucceed;
    
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1)break;
        if (readBytesCount == 0) {
            hasMoreData =false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 *sizeof(digest) + 1];
    for (size_t i =0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i),3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    
done:
    
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}



@end
