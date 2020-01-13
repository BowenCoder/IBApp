//
//  IBEncode.m
//  IBApplication
//
//  Created by Bowen on 2018/6/26.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBEncode.h"
#import <zlib.h>
#import <Availability.h>
#include <CommonCrypto/CommonCrypto.h>

#define FileHashDefaultChunkSizeForReadingData 1024*8 // 8K
#define SCFW_CHUNK_SIZE 16384

@implementation IBEncode

#pragma mark - MD5

/**
 *  返回md5编码的字符串
 */
+ (NSString *)md5WithString:(NSString *)string {
    
    if(!string){
        return nil;//判断sourceString如果为空则直接返回nil。
    }
    //MD5加密都是通过C级别的函数来计算，所以需要将加密的字符串转换为C语言的字符串
    const char *cString = string.UTF8String;
    //创建一个C语言的字符数组，用来接收加密结束之后的字符
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //MD5计算（也就是加密）
    //第一个参数：需要加密的字符串
    //第二个参数：需要加密的字符串的长度
    //第三个参数：加密完成之后的字符串存储的地方
    CC_MD5(cString, (CC_LONG)strlen(cString), result);
    //将加密完成的字符拼接起来使用（16进制的）。
    //声明一个可变字符串类型，用来拼接转换好的字符
    NSMutableString *resultString = [[NSMutableString alloc]init];
    //遍历所有的result数组，取出所有的字符来拼接
    for (int i = 0;i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString  appendFormat:@"%02x",result[i]];
        //%02x：x 表示以十六进制形式输出，02 表示不足两位，前面补0输出；超出两位，不影响。当x小写的时候，返回的密文中的字母就是小写的，当X大写的时候返回的密文中的字母是大写的。
    }
    return [resultString lowercaseString];
}

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
    
    if (!path) {
        return nil;
    }
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

#pragma mark - NSDataBase64

/**
 *  @brief  base64字符串解码
 *
 *  @param string base64字符串
 *
 *  @return 返回解码后的data
 */
+ (NSData *)decodeBase64:(NSString *)string {
    
    if (![string length]) return nil;
    NSData *decoded = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        decoded = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    return decoded;
}

/**
 *  @brief  NSData转string 换行长度默认64
 *
 *  @return base64后的字符串
 */
+ (NSString *)encodeBase64:(NSData *)data {
    
    return [self _base64EncodedStringWithData:data width:0];
}

/**
 *  @brief  NSData转string
 *
 *  @param data  二进制数据
 *  @param width 换行长度  76  64
 *
 *  @return base64后的字符串
 */
+ (NSString *)_base64EncodedStringWithData:(NSData *)data width:(NSUInteger)width {
    
    if (![data length]) return nil;
    NSString *encoded = nil;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        switch (width) {
             case 64: {
                 return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
             }
             case 76: {
                 return [data base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
             }
             default: {
                 encoded = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
             }
         }
    }
    
    if (!width || width >= [encoded length]) {
        return encoded;
    }
    width = (width / 4) * 4;
    NSMutableString *result = [NSMutableString string];
    for (NSUInteger i = 0; i < [encoded length]; i+= width) {
        if (i + width >= [encoded length]) {
            [result appendString:[encoded substringFromIndex:i]];
            break;
        }
        [result appendString:[encoded substringWithRange:NSMakeRange(i, width)]];
        [result appendString:@"\r\n"];
    }
    return result;
}

#pragma mark - NSDataHash

/**
 *  @brief           键控哈希算法
 *
 *  @param data      二进制
 *  @param key       密钥
 *  @param option    算法类型
 *
 *  @return          结果
 */
+ (NSData *)hmac:(NSData *)data key:(NSString *)key option:(IBEncodeHmacOption)option {
    
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    CCHmacAlgorithm rule;
    size_t digestLength;
    
    switch (option) {
        case IBEncodeHmacOptionSHA1:
            rule         = kCCHmacAlgSHA1;
            digestLength = CC_SHA1_DIGEST_LENGTH;
            break;
        case IBEncodeHmacOptionMD5:
            rule         = kCCHmacAlgMD5;
            digestLength = CC_MD5_DIGEST_LENGTH;
            break;
        case IBEncodeHmacOptionSHA256:
            rule         = kCCHmacAlgSHA256;
            digestLength = CC_SHA256_DIGEST_LENGTH;
            break;
        case IBEncodeHmacOptionSHA384:
            rule         = kCCHmacAlgSHA384;
            digestLength = CC_SHA384_DIGEST_LENGTH;
            break;
        case IBEncodeHmacOptionSHA512:
            rule         = kCCHmacAlgSHA512;
            digestLength = CC_SHA512_DIGEST_LENGTH;
            break;
        case IBEncodeHmacOptionSHA224:
            rule         = kCCHmacAlgSHA224;
            digestLength = CC_SHA224_DIGEST_LENGTH;
            break;
            
        default:
            break;
    }
    
    unsigned char result[digestLength];
    CCHmac(rule, [keyData bytes], key.length, data.bytes, data.length, result);
    return [NSData dataWithBytes:result length:digestLength];
}

/**
 *  @brief           哈希算法
 *
 *  @param data      二进制
 *  @param option    算法类型
 *
 *  @return          结果
 */
+ (NSData *)hash:(NSData *)data option:(IBEncodeHashOption)option {
    
    NSData *newData;
    switch (option) {
        case IBEncodeHashOptionSHA1: {
            unsigned char bytes[CC_SHA1_DIGEST_LENGTH];
            CC_SHA1(data.bytes, (CC_LONG)data.length, bytes);
            newData =[NSData dataWithBytes:bytes length:CC_SHA1_DIGEST_LENGTH];
        }
            break;
        case IBEncodeHashOptionMD5: {
            unsigned char bytes[CC_MD5_DIGEST_LENGTH];
            CC_MD5(data.bytes, (CC_LONG)data.length, bytes);
            newData = [NSData dataWithBytes:bytes length:CC_MD5_DIGEST_LENGTH];
        }
            break;
        case IBEncodeHashOptionSHA256: {
            unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
            CC_SHA256(data.bytes, (CC_LONG)data.length, bytes);
            newData = [NSData dataWithBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
        }
            break;
        case IBEncodeHashOptionSHA384: {
            unsigned char bytes[CC_SHA384_DIGEST_LENGTH];
            CC_SHA384(data.bytes, (CC_LONG)data.length, bytes);
            newData = [NSData dataWithBytes:bytes length:CC_SHA384_DIGEST_LENGTH];
        }
            break;
        case IBEncodeHashOptionSHA512: {
            unsigned char bytes[CC_SHA512_DIGEST_LENGTH];
            CC_SHA512(data.bytes, (CC_LONG)data.length, bytes);
            newData = [NSData dataWithBytes:bytes length:CC_SHA512_DIGEST_LENGTH];
        }
            break;
        case IBEncodeHashOptionSHA224: {
            unsigned char bytes[CC_SHA224_DIGEST_LENGTH];
            CC_SHA512(data.bytes, (CC_LONG)data.length, bytes);
            newData = [NSData dataWithBytes:bytes length:CC_SHA224_DIGEST_LENGTH];
        }
            break;
        default:
            break;
    }
    
    return newData;
}

#pragma mark - NSDataGzip

/**
 *  @brief  compressedData 压缩后的数据
 *
 *  @return 是否压缩
 */
+ (BOOL)isGzippedData:(NSData *)compressedData {
    
    const UInt8 *bytes = (const UInt8 *)compressedData.bytes;
    return (compressedData.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b);
}

/**
 *  @brief  GZIP压缩 压缩级别 默认-1
 *
 *  @param  data      二进制
 *
 *  @return 压缩后的数据
 */
+ (NSData *)gzippedData:(NSData *)data {
    
    return [IBEncode gzippedData:data compressionLevel:-1.0f];
}

/**
 *  @brief  GZIP解压
 *
 *  @param  data      二进制
 *
 *  @return 解压后数据
 */
+ (NSData *)gunzippedData:(NSData *)data {
    
    if ([data length]) {
        z_stream stream;
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.avail_in = (uint)[data length];
        stream.next_in = (Bytef *)[data bytes];
        stream.total_out = 0;
        stream.avail_out = 0;
        
        NSMutableData *newData = [NSMutableData dataWithLength: [data length] * 1.5];
        if (inflateInit2(&stream, 47) == Z_OK) {
            int status = Z_OK;
            while (status == Z_OK) {
                if (stream.total_out >= [newData length]) {
                    newData.length += [data length] * 0.5;
                }
                stream.next_out = [newData mutableBytes] + stream.total_out;
                stream.avail_out = (uint)([newData length] - stream.total_out);
                status = inflate (&stream, Z_SYNC_FLUSH);
            }
            if (inflateEnd(&stream) == Z_OK) {
                if (status == Z_STREAM_END) {
                    newData.length = stream.total_out;
                    return newData;
                }
            }
        }
    }
    return nil;
}

/**
 *  @brief  GZIP压缩
 *
 *  @param level 压缩级别
 *
 *  @return 压缩后的数据
 */
+ (NSData *)gzippedData:(NSData *)data compressionLevel:(float)level {
    
    if ([data length]) {
        z_stream stream;
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.opaque = Z_NULL;
        stream.avail_in = (uint)[data length];
        stream.next_in = (Bytef *)[data bytes];
        stream.total_out = 0;
        stream.avail_out = 0;
        
        int compression = (level < 0.0f) ? Z_DEFAULT_COMPRESSION : (int)roundf(level * 9);
        if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK) {
            NSMutableData *data = [NSMutableData dataWithLength:SCFW_CHUNK_SIZE];
            while (stream.avail_out == 0) {
                if (stream.total_out >= [data length]) {
                    data.length += SCFW_CHUNK_SIZE;
                }
                stream.next_out = [data mutableBytes] + stream.total_out;
                stream.avail_out = (uint)([data length] - stream.total_out);
                deflate(&stream, Z_FINISH);
            }
            deflateEnd(&stream);
            data.length = stream.total_out;
            return data;
        }
    }
    return nil;
}

#pragma mark - NSStringEncode

/**
 *  对url进行编码
 *
 *  @param  string url字符串
 *
 *  @return 编码好的字符串
 */
+ (NSString *)URLEncode:(NSString *)string {
    
    if ([string isKindOfClass:[NSNull class]]) {
        return nil;
    }
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    }
    return nil;
}

/**
 *  对url进行解码
 *
 *  @param  string url字符串
 *
 *  @return 解码好的字符串
 */
+ (NSString *)URLDecode:(NSString *)string {
    
    if ([string isKindOfClass:[NSNull class]]) {
        return nil;
    }
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return [string stringByRemovingPercentEncoding];
    }
    return nil;
}

/**
 *  @brief  Unicode字符串转成NSString
 *
 *  @param  string Unicode字符串
 *
 *  @return Unicode字符串转成NSString
 */
+ (NSString *)transformUnicode:(NSString *)string {
    
    NSString *tempStr1 = [string stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

+ (NSString *)base64Encode:(NSString *)string {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [IBEncode encodeBase64:data];
}

+ (NSString *)base64Decode:(NSString *)string {
    
    NSData *data = [IBEncode decodeBase64:string];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

/**
 *  返回sha1编码的字符串
 */
+ (NSString *)sha1:(NSString *)string {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    data = [IBEncode hash:data option:IBEncodeHashOptionSHA1];
    return [self _convertByte:(unsigned char *)data.bytes length:data.length];
}

/**
 *  返回sha256编码的字符串
 */
+ (NSString *)sha256:(NSString *)string {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    data = [IBEncode hash:data option:IBEncodeHashOptionSHA256];
    return [self _convertByte:(unsigned char *)data.bytes length:data.length];
}

/**
 *  返回sha512编码的字符串
 */
+ (NSString *)sha512:(NSString *)string {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    data = [IBEncode hash:data option:IBEncodeHashOptionSHA512];
    return [self _convertByte:(unsigned char *)data.bytes length:data.length];
}

+ (NSString *)_convertByte:(unsigned char *)bytes length:(NSUInteger)length{
    
    NSMutableString *string = [[NSMutableString alloc] init];
    for(int i = 0; i< length; i++) {
        [string appendFormat:@"%02x", bytes[i]];
    }
    return string;
}

@end

