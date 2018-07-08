//
//  IBApp.m
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBApp.h"
#import "NSHelper.h"
#import "NSFile.h"

#import <AudioToolbox/AudioToolbox.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import <sys/socket.h>
#import <sys/param.h>
#import <sys/mount.h>
#import <sys/stat.h>
#import <sys/utsname.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <mach/processor_info.h>

@implementation IBApp

+ (NSString *)UUID {
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] > 6.0) {
        return  [[NSUUID UUID] UUIDString];
    } else {
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuid = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        return (__bridge_transfer NSString *)uuid;
    }
}

+ (UIImage *)appIcon {
    
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    UIImage *appIcon = [UIImage imageNamed:icon] ;
    return appIcon;
}

+ (void)shakeDevice {
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (NSString *)cacheSize {
    
    unsigned long long docSize   =  [self _sizeOfFolder:[NSFile pathForDocumentsDirectory] resetSize:YES];
    unsigned long long cacheSize =  [self _sizeOfFolder:[NSFile pathForCachesDirectory] resetSize:YES];
    unsigned long long tempSize  =  [self _sizeOfFolder:[NSFile pathForTemporaryDirectory] resetSize:YES];
    
    unsigned long long total = docSize + cacheSize + tempSize;
    
    NSString *folderSize = [NSByteCountFormatter stringFromByteCount:total countStyle:NSByteCountFormatterCountStyleFile];
    
    return folderSize;
}

+ (NSString *)APNSToken:(NSData *)tokenData {
    
    return [[[[tokenData description]
              stringByReplacingOccurrencesOfString: @"<" withString: @""]
             stringByReplacingOccurrencesOfString: @">" withString: @""]
            stringByReplacingOccurrencesOfString: @" " withString: @""];
}

/**
 *  截取想要的view生成一张图片
 *
 *  @param view 要截的view
 *
 *  @return 生成的图片
 */
+ (UIImage *)shotView:(UIView *)view bounds:(CGRect)bounds{
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    if( [view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]){
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    }else{
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
}

/**
 *  截屏
 *
 *  @return 返回截取的屏幕的图像
 */
+ (UIImage *)screenShot {
    
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    //开启图形上下文
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            CGContextConcatCTM(context, [window transform]);
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            [[window layer] renderInContext:context];
            
            CGContextRestoreGState(context);
        }
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (BOOL)isFirstStartForVersion:(NSString * _Nonnull)version {
    
    NSString *versionKey = [NSString stringWithFormat:@"NSApp_v%@", version];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *oldVersion = [defaults valueForKey:versionKey];
    if ([NSHelper isEmptyString:oldVersion]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)onFirstStartForVersion:(NSString *)version block:(void (^)(BOOL isFirstStartForVersion))block {
    
    if ([NSHelper isEmptyString:version]) {
        version = APP_VERSION;
    }
    NSString *versionKey = [NSString stringWithFormat:@"NSApp_v%@", version];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *oldVersion = [defaults valueForKey:versionKey];
    if ([oldVersion isEqualToString:version]) {
        block(NO);
    } else {
        [defaults setValue:version forKey:versionKey];
        [defaults synchronize];
        block(YES);
    }
}

+ (unsigned long long)_sizeOfFolder:(NSString *)folderPath resetSize:(BOOL)reset{
    
    static unsigned long long folderSize;
    if (reset) {
        folderSize = 0;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *contents = [manager contentsOfDirectoryAtPath:folderPath error:nil];
    
    for(int i = 0; i<[contents count]; i++) {
        NSString *fullPath = [folderPath stringByAppendingPathComponent:[contents objectAtIndex:i]];
        BOOL isDir;
        if ( !([manager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) ) {
            NSDictionary *fileAttributes = [manager attributesOfItemAtPath:fullPath error:nil];
            folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
        }
        else {
            [self _sizeOfFolder:fullPath resetSize:NO];
        }
    }
    return folderSize;
}

@end

@implementation IBApp (Open)

+ (void)openURL:(NSURL *)url {
    
    [[UIApplication sharedApplication] openURL:url];
}

+ (void)sendMail:(NSString *)mail {
    
    NSString *url = [NSString stringWithFormat:@"mailto://%@", mail];
    [self openURL:[NSURL URLWithString:url]];
}

+ (void)sendSMS:(NSString *)number {
    
    NSString *url = [NSString stringWithFormat:@"sms://%@", number];
    [self openURL:[NSURL URLWithString:url]];
}

+ (void)callNumber:(NSString *)number {
    
    NSString *url = [NSString stringWithFormat:@"tel://%@", number];
    [self openURL:[NSURL URLWithString:url]];
}

@end

@implementation IBApp (Device)

+ (CGFloat)cpuUsage {
    
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0;
    
    basic_info = (task_basic_info_t)tinfo;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0) stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

+ (NSUInteger)systemInformation:(uint)typeSpecifier {
    
    size_t size = sizeof(int);
    int result;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &result, &size, NULL, 0);
    return (NSUInteger)result;
}

+ (NSUInteger)cpuFrequency {
    
    return [self systemInformation:HW_CPU_FREQ];
}

+ (NSUInteger)busFrequency {
    
    return [self systemInformation:HW_BUS_FREQ];
}

+ (NSUInteger)ramSize {
    
    return [self systemInformation:HW_MEMSIZE];
}

+ (NSUInteger)cpuNumber {
    
    return [self systemInformation:HW_NCPU];
}

+ (NSUInteger)totalMemoryBytes {
    
    return [self systemInformation:HW_PHYSMEM];
}

+ (NSUInteger)freeMemoryBytes {
    
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        return 0;
    }
    unsigned long mem_free = vm_stat.free_count * pagesize;
    return mem_free;
}

+ (NSUInteger)freeDiskSpaceBytes {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = [fileManager attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSNumber *number = attributes[NSFileSystemFreeSize];
    return [number unsignedIntegerValue];
}

+ (NSUInteger)totalDiskSpaceBytes {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = [fileManager attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSNumber *number = attributes[NSFileSystemSize];
    return [number unsignedIntegerValue];
}


@end


