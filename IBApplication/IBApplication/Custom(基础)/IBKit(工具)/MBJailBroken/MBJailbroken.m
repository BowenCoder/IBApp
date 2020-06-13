//
//  GMJailbroken.m
//  IBApplication
//
//  Created by Bowen on 2019/11/27.
//  Copyright © 2019 Bowen. All rights reserved.
//

#import "MBJailbroken.h"
#import <sys/stat.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

@implementation MBJailbroken

+ (void)checkJailbroken:(void(^)(BOOL jailbroken, NSString *msg))completion
{
    BOOL isJailbroken = NO;
    NSString *msg = @"未越狱";
            
    if ([self checkFile]) {
        isJailbroken = YES;
        msg = @"fileExistsAtPath方法检测";
        goto jailbrokend;
    }
    if ([self checkReadFile]) {
        isJailbroken = YES;
        msg = @"initWithContentsOfFile方法检测";
        goto jailbrokend;
    }
    if ([self checkCydia]) {
        isJailbroken = YES;
        msg = @"stat系列函数检测";
        goto jailbrokend;
    }
    if ([self checkCanOpen]) {
        isJailbroken = YES;
        msg = @"canOpenURL方法检测";
        goto jailbrokend;
    }
    if ([self checkStat]) {
        isJailbroken = YES;
        msg = @"检测stat是否出自系统库";
        goto jailbrokend;
    }
    if ([self checkEnv]) {
        isJailbroken = YES;
        msg = @"检测当前程序运行的环境变量";
        goto jailbrokend;
    }
    if ([self checkDylibs]) {
        isJailbroken = YES;
        msg = @"检查动态库列表";
        goto jailbrokend;
    }
    if ([self checkCracked]) {
        isJailbroken = YES;
        msg = @"检查签名和源码是否被修改";
        goto jailbrokend;
    }
    
jailbrokend:
    
    completion(isJailbroken, msg);
}

// 可能存在 hook NSFileManager 的方法
+ (BOOL)checkFile
{
    BOOL root = NO;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSArray *pathArray = @[@"/etc/ssh/sshd_config",
                           @"/usr/libexec/ssh-keysign",
                           @"/usr/sbin/sshd",
                           @"/usr/sbin/sshd",
                           @"/bin/sh",
                           @"/bin/bash",
                           @"/etc/apt",
                           @"/Application/Cydia.app/",
                           @"/Library/MobileSubstrate/MobileSubstrate.dylib"
                           ];
    for (NSString *path in pathArray) {
        root = [fileManager fileExistsAtPath:path];
      // 如果存在这些目录，就是已经越狱
        if (root) {
          break;
        }
    }
    return root;
}

// 判断文件是否存在的方法有可能会被 hook， 因此我们可以直接读取相关的文件来判断设备是否经过越狱
+ (BOOL)checkReadFile
{
    NSString *strPath = @"/Applications/Cydia.app/Cydia";
    NSData *data = [[NSData alloc] initWithContentsOfFile:strPath];
    return data != nil;
}

// 判断canOpenURL是否能打开cydia
+ (BOOL)checkCanOpen
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]];
}

// 防hook NSFileManager的方法  使用stat系列函数检测Cydia等工具，路径同上
+ (BOOL)checkCydia
{
    struct stat stat_info;
    if (0 == stat("/Applications/Cydia.app", &stat_info)) {
        return YES;
    }
    return NO;
}

// 检测stat是否出自系统库
+ (BOOL)checkStat
{
     int ret;
     Dl_info dylib_info;
     int (*func_stat)(const char *, struct stat *) = stat;
     if ((ret = dladdr((const void *)func_stat, &dylib_info))) {
         NSString *dlfname = [NSString stringWithUTF8String:dylib_info.dli_fname];
         if (![@"/usr/lib/system/libsystem_kernel.dylib" isEqualToString:dlfname]) {
             return YES;
         }
     }
    return NO;
}

// 检测当前程序运行的环境变量，防止通过 DYLD_INSERT_LIBRARIES 注入链接异常动态库，来更改相关工具名称
+ (BOOL)checkEnv
{
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (env) {
        return YES;
    } else {
        return NO;
    }
}

// 检查动态库列表
+ (BOOL)checkDylibs
{
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0 ; i < count; ++i) {
        const char *name = _dyld_get_image_name(i);
        if (strstr(name, "MobileSubstrate.dylib")) {
            return YES;
        }
    }
    return NO;
}

// 检查签名和源码是否被修改
+ (BOOL)checkCracked
{
    // Check process ID (shouldn't be root)
    int root = getgid();
    if (root <= 10) {
        return YES;
    }
    
    // Check SignerIdentity
    char symCipher[] = {
        '(', 'H',  'Z', '[',  '9', '{', '+', 'k', ',', 'o', 'g', 'U', ':', 'D',
        'L', '#',  'S', ')',  '!', 'F', '^', 'T', 'u', 'd', 'a', '-', 'A', 'f',
        'z', ';',  'b', '\'', 'v', 'm', 'B', '0', 'J', 'c', 'W', 't', '*', '|',
        'O', '\\', '7', 'E',  '@', 'x', '"', 'X', 'V', 'r', 'n', 'Q', 'y', '>',
        ']', '$',  '%', '_',  '/', 'P', 'R', 'K', '}', '?', 'I', '8', 'Y', '=',
        'N', '3',  '.', 's',  '<', 'l', '4', 'w', 'j', 'G', '`', '2', 'i', 'C',
        '6', 'q',  'M', 'p',  '1', '5', '&', 'e', 'h'};
    char csignid[] = "V.NwY2*8YwC.C1";
    for (int i = 0; i < strlen(csignid); i++) {
        for (int j = 0; j < sizeof(symCipher); j++) {
            if (csignid[i] == symCipher[j]) {
                csignid[i] = j + 0x21;
                break;
            }
        }
    }
    NSString *signIdentity =
    [[NSString alloc] initWithCString:csignid encoding:NSUTF8StringEncoding];
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    if ([info objectForKey:signIdentity] != nil) {
        return YES;
    }
    
    // Check files
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSFileManager *manager = [NSFileManager defaultManager];
    static NSString *str = @"_CodeSignature";
    BOOL fileExists = [manager
                       fileExistsAtPath:([NSString stringWithFormat:@"%@/%@", bundlePath, str])];
    if (!fileExists) {
        return YES;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/Info.plist", bundlePath];
    NSString *path2 = [NSString stringWithFormat:@"%@/AppName", bundlePath];
    NSDate *infoModifiedDate = [[manager attributesOfFileSystemForPath:path error:nil] fileModificationDate];
    NSDate *infoModifiedDate2 = [[manager attributesOfFileSystemForPath:path2 error:nil] fileModificationDate];
    NSDate *pkgInfoModifiedDate = [[manager attributesOfFileSystemForPath:
                                    [[[NSBundle mainBundle] resourcePath]
                                     stringByAppendingPathComponent:@"PkgInfo"]
                                                                    error:nil] fileModificationDate];
    if ([infoModifiedDate timeIntervalSinceReferenceDate] >
        [pkgInfoModifiedDate timeIntervalSinceReferenceDate]) {
        return YES;
    }
    if ([infoModifiedDate2 timeIntervalSinceReferenceDate] >
        [pkgInfoModifiedDate timeIntervalSinceReferenceDate]) {
        return YES;
    }
    
    return NO;
}

@end
