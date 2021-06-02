//
//  IBApp.m
//  IBApplication
//
//  Created by Bowen on 2018/6/24.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBApp.h"
#import "IBFile.h"
#import "IBMacros.h"
#import "MBJailbroken.h"
#import "MBLogger.h"
#include <sys/sysctl.h>
#import <sys/utsname.h>
#import <mach/mach.h>
#import <AdSupport/AdSupport.h>
#import <AudioToolbox/AudioToolbox.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation IBApp

#pragma mark - Basic

- (UIWindow *)keyWindow {
    UIWindow *keyWindow;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        return window;
                    }
                }
            }
        }
    } else {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    return keyWindow;
}

+ (NSInteger)OSVersion
{
    static NSInteger OSVersion = 0;
    
    if (OSVersion > 0) {
        return OSVersion;
    }
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSArray *systemVersionArray = [systemVersion componentsSeparatedByString:@"."];
    
    NSInteger pos = 0;
    
    while ([systemVersionArray count] > pos && pos < 3) {
        OSVersion += ([[systemVersionArray objectAtIndex:pos] integerValue] * pow(10, (4 - pos * 2)));
        pos++;
    }
    
    return OSVersion;
}

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

+ (NSString *)idfa
{
    ASIdentifierManager *mgr = [ASIdentifierManager sharedManager];
    if (mgr.isAdvertisingTrackingEnabled) {
        NSUUID *rv = mgr.advertisingIdentifier;
        while (!rv) {
            [NSThread sleepForTimeInterval:0.005];
            rv = mgr.advertisingIdentifier;
        }
        return rv.UUIDString;
    } else {
        return nil;
    }
}

+ (NSString *)idfv
{
    UIDevice *device = [UIDevice currentDevice];
    NSUUID *rv = device.identifierForVendor;
    while (!rv) { // 设备重启没有解锁，但是应用在后台已被唤醒，可能为nil
        [NSThread sleepForTimeInterval:0.005];
        rv = device.identifierForVendor;
    }
    return rv.UUIDString;
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
    
    unsigned long long docSize   =  [self _sizeOfFolder:[IBFile documentPath] resetSize:YES];
    unsigned long long cacheSize =  [self _sizeOfFolder:[IBFile cachePath] resetSize:YES];
    unsigned long long tempSize  =  [self _sizeOfFolder:[IBFile temporaryPath] resetSize:YES];
    
    unsigned long long total = docSize + cacheSize + tempSize;
    
    NSString *folderSize = [NSByteCountFormatter stringFromByteCount:total countStyle:NSByteCountFormatterCountStyleFile];
    
    return folderSize;
}

+ (BOOL)emptyCaches {
    return [IBFile emptyCachesPath] && [IBFile emptyTemporaryPath];
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
    
    if (kIsEmptyString(oldVersion)) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)onFirstStartForVersion:(NSString *)version block:(void (^)(BOOL isFirstStartForVersion))block {
    
    if (kIsEmptyString(version)) {
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

+ (void)checkAppVersionInStore:(NSString *)appID block:(void(^)(NSString *storeVersion, NSString *openUrl,BOOL update))block {
    NSURLRequest *request;
    if (appID) {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",appID]]];
    } else {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@&country=cn",APP_BUNDLEID]]];
    }
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) { //失败
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil,nil,NO);
            });
            return;
        }
        NSDictionary *appInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([appInfo[@"resultCount"] integerValue] == 0) { //APP未上架或者已下架
                block(nil,nil,NO);
                return;
            }
            NSString *appStoreVersion = appInfo[@"results"][0][@"version"];
            if ([APP_VERSION floatValue] < [appStoreVersion floatValue]) {
                block(appInfo[@"results"][0][@"version"],appInfo[@"results"][0][@"trackViewUrl"],YES);
            } else {
                block(appInfo[@"results"][0][@"version"],appInfo[@"results"][0][@"trackViewUrl"],NO);
            }
        });
    }];
    
    [task resume];
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

#pragma mark - Open

+ (BOOL)canOpenURL:(NSURL *)url {
    return [[UIApplication sharedApplication] canOpenURL:url];
}

+ (void)openURL:(NSURL *)url {
    if ([self canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            }];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
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

+ (void)openSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [self openURL:url];
}

#pragma mark - Device

+ (BOOL)isIPad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (BOOL)isIPod {
    NSString *string = [[UIDevice currentDevice] model];
    return [string rangeOfString:@"iPod touch"].location != NSNotFound;
}

+ (BOOL)isIPhone {
    NSString *string = [[UIDevice currentDevice] model];
    return [string rangeOfString:@"iPhone"].location != NSNotFound;
}

+ (BOOL)isSimulator {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

+ (BOOL)isJailbroken {
    if ([self isSimulator]) return NO; // 不要检查模拟器
    __block BOOL res = NO;
    [MBJailbroken checkJailbroken:^(BOOL jailbroken, NSString * _Nonnull msg) {
        res = jailbroken;
        MBLogI(@"%@", msg);
    }];
    return res;
}

+ (NSString *)machineModel {
    if ([self isSimulator]) {
        // Simulator doesn't return the identifier for the actual physical model, but returns it as an environment variable
        // 模拟器不返回物理机器信息，但会通过环境变量的方式返回
        return [NSString stringWithFormat:@"%s", getenv("SIMULATOR_MODEL_IDENTIFIER")];
    }
    
    // See https://www.theiphonewiki.com/wiki/Models for identifiers
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    machine = [machine stringByReplacingOccurrencesOfString:@"," withString:@"_"];
    return machine;
}

+ (CGFloat)batteryLevel {
    return [[UIDevice currentDevice] batteryLevel];
}

+ (id)wifiSSID
{
    id info = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) { break; }
    }
    return info;
}

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


