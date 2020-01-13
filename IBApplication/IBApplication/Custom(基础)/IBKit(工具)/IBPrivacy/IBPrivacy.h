//
//  IBPrivacy.h
//  IBApplication
//
//  Created by Bowen on 2018/7/13.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,IBPrivacyPermissionType) {
    IBPrivacyPermissionPhoto = 0,  // 相册/PhotoLibrary
    IBPrivacyPermissionCamera,     // 相机/Camera
    IBPrivacyPermissionMedia,      // 媒体资料库/AppleMusic
    IBPrivacyPermissionMicrophone, // 麦克风/Audio
    IBPrivacyPermissionLocation,   // 定位
    IBPrivacyPermissionBluetooth,  // 蓝牙共享/Bluetooth
    IBPrivacyPermissionPushNotification, //通知
    IBPrivacyPermissionSpeech,     //语音识别/SpeechRecognizer
    IBPrivacyPermissionEvent,      //日历事件
    IBPrivacyPermissionContact,    // 通讯录/AddressBook
    IBPrivacyPermissionReminder,   // 提醒事项/Reminder
    IBPrivacyPermissionHealth,     // 健康
    IBPrivacyPermissionSiri        // Siri(must in iOS10 or later)
};

typedef NS_ENUM(NSUInteger,IBPrivacyAuthorizationStatus) {
    IBPrivacyAuthorizationAuthorized = 0,
    IBPrivacyAuthorizationDenied,
    IBPrivacyAuthorizationNotDetermined,
    IBPrivacyAuthorizationRestricted,
    IBPrivacyAuthorizationLocationAlways,
    IBPrivacyAuthorizationLocationWhenInUse,
    IBPrivacyAuthorizationUnkonwn
};

@interface IBPrivacy : NSObject

+ (void)accessPrivacyPermissionWithType:(IBPrivacyPermissionType)type completion:(void(^)(BOOL result,IBPrivacyAuthorizationStatus status))completion;


@end
