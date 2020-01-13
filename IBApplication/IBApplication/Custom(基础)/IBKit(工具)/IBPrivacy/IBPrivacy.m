//
//  IBPrivacy.m
//  IBApplication
//
//  Created by Bowen on 2018/7/13.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBPrivacy.h"
#import <Photos/Photos.h>
#import <Speech/Speech.h>
#import <Intents/Intents.h>
#import <EventKit/EventKit.h>
#import <Contacts/Contacts.h>
#import <HealthKit/HealthKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UserNotifications/UserNotifications.h>

@implementation IBPrivacy

+ (void)accessPrivacyPermissionWithType:(IBPrivacyPermissionType)type completion:(void(^)(BOOL result, IBPrivacyAuthorizationStatus status))completion {
    
    switch (type) {
        case IBPrivacyPermissionPhoto:{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusDenied) {
                    completion(NO,IBPrivacyAuthorizationDenied);
                } else if (status == PHAuthorizationStatusNotDetermined) {
                    completion(NO,IBPrivacyAuthorizationNotDetermined);
                } else if (status == PHAuthorizationStatusRestricted) {
                    completion(NO,IBPrivacyAuthorizationRestricted);
                } else if (status == PHAuthorizationStatusAuthorized) {
                    completion(YES,IBPrivacyAuthorizationAuthorized);
                }
            }];
        } break;
            
        case IBPrivacyPermissionCamera:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if (granted) {
                    completion(YES,IBPrivacyAuthorizationAuthorized);
                } else {
                    if (status == AVAuthorizationStatusDenied) {
                        completion(NO,IBPrivacyAuthorizationDenied);
                    } else if (status == AVAuthorizationStatusNotDetermined) {
                        completion(NO,IBPrivacyAuthorizationNotDetermined);
                    } else if (status == AVAuthorizationStatusRestricted) {
                        completion(NO,IBPrivacyAuthorizationRestricted);
                    }
                }
            }];
        } break;
            
        case IBPrivacyPermissionMedia:{
            if (@available(iOS 9.3, *)) {
                [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
                    if (status == MPMediaLibraryAuthorizationStatusDenied) {
                        completion(NO,IBPrivacyAuthorizationDenied);
                    } else if (status == MPMediaLibraryAuthorizationStatusNotDetermined) {
                        completion(NO,IBPrivacyAuthorizationNotDetermined);
                    } else if (status == MPMediaLibraryAuthorizationStatusRestricted) {
                        completion(NO,IBPrivacyAuthorizationRestricted);
                    } else if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
                        completion(YES,IBPrivacyAuthorizationAuthorized);
                    }
                }];
            }
        } break;
            
        case IBPrivacyPermissionMicrophone:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
                if (granted) {
                    completion(YES,IBPrivacyAuthorizationAuthorized);
                } else {
                    if (status == AVAuthorizationStatusDenied) {
                        completion(NO,IBPrivacyAuthorizationDenied);
                    } else if (status == AVAuthorizationStatusNotDetermined) {
                        completion(NO,IBPrivacyAuthorizationNotDetermined);
                    } else if (status == AVAuthorizationStatusRestricted) {
                        completion(NO,IBPrivacyAuthorizationRestricted);
                    }
                }
            }];
        } break;
            
        case IBPrivacyPermissionLocation:{
            if ([CLLocationManager locationServicesEnabled]) {
                CLLocationManager *locationManager = [[CLLocationManager alloc]init];
                [locationManager requestAlwaysAuthorization];
                [locationManager requestWhenInUseAuthorization];
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
                locationManager.distanceFilter = 10;
                [locationManager startUpdatingLocation];
            }
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if (status == kCLAuthorizationStatusAuthorizedAlways) {
                completion(YES,IBPrivacyAuthorizationLocationAlways);
            } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                completion(YES,IBPrivacyAuthorizationLocationWhenInUse);
            } else if (status == kCLAuthorizationStatusDenied) {
                completion(NO,IBPrivacyAuthorizationDenied);
            } else if (status == kCLAuthorizationStatusNotDetermined) {
                completion(NO,IBPrivacyAuthorizationNotDetermined);
            } else if (status == kCLAuthorizationStatusRestricted) {
                completion(NO,IBPrivacyAuthorizationRestricted);
            }
        } break;
            
        case IBPrivacyPermissionBluetooth:{
            if (@available(iOS 10.0, *)) {
                CBCentralManager *centralManager = [[CBCentralManager alloc] init];
                CBManagerState state = [centralManager state];
                if (state == CBManagerStateUnsupported || state == CBManagerStateUnauthorized || state == CBManagerStateUnknown) {
                    completion(NO,IBPrivacyAuthorizationDenied);
                } else {
                    completion(YES,IBPrivacyAuthorizationAuthorized);
                }
            }
        } break;
            
        case IBPrivacyPermissionPushNotification:{
            
            if (@available(iOS 10.0, *)) {
                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                UNAuthorizationOptions types=UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
                [center requestAuthorizationWithOptions:types completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    if (granted) {
                        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                        }];
                        completion(YES,IBPrivacyAuthorizationAuthorized);
                    } else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@""} completionHandler:^(BOOL success) { }];
                    }
                }];
            } else {
                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
            }
        } break;
            
        case IBPrivacyPermissionSpeech:{
            if (@available(iOS 10.0, *)) {
                [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
                    if (status == SFSpeechRecognizerAuthorizationStatusDenied) {
                        completion(NO,IBPrivacyAuthorizationDenied);
                    } else if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
                        completion(NO,IBPrivacyAuthorizationNotDetermined);
                    } else if (status == SFSpeechRecognizerAuthorizationStatusRestricted) {
                        completion(NO,IBPrivacyAuthorizationRestricted);
                    } else if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                        completion(YES,IBPrivacyAuthorizationAuthorized);
                    }
                }];
            }
        } break;
            
        case IBPrivacyPermissionEvent:{
            EKEventStore *store = [[EKEventStore alloc]init];
            [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
                EKAuthorizationStatus status = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];
                if (granted) {
                    completion(YES,IBPrivacyAuthorizationAuthorized);
                } else {
                    if (status == EKAuthorizationStatusDenied) {
                        completion(NO,IBPrivacyAuthorizationDenied);
                    } else if (status == EKAuthorizationStatusNotDetermined) {
                        completion(NO,IBPrivacyAuthorizationNotDetermined);
                    } else if (status == EKAuthorizationStatusRestricted) {
                        completion(NO,IBPrivacyAuthorizationRestricted);
                    }
                }
            }];
        } break;
            
        case IBPrivacyPermissionContact:{
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
                if (granted) {
                    completion(YES,IBPrivacyAuthorizationAuthorized);
                } else {
                    if (status == CNAuthorizationStatusDenied) {
                        completion(NO,IBPrivacyAuthorizationDenied);
                    }else if (status == CNAuthorizationStatusRestricted){
                        completion(NO,IBPrivacyAuthorizationRestricted);
                    }else if (status == CNAuthorizationStatusNotDetermined){
                        completion(NO,IBPrivacyAuthorizationNotDetermined);
                    }
                }
            }];
        } break;
            
        case IBPrivacyPermissionReminder:{
            EKEventStore *eventStore = [[EKEventStore alloc]init];
            [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
                EKAuthorizationStatus status = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];
                if (granted) {
                    completion(YES,IBPrivacyAuthorizationAuthorized);
                } else {
                    if (status == EKAuthorizationStatusDenied) {
                        completion(NO,IBPrivacyAuthorizationDenied);
                    }else if (status == EKAuthorizationStatusNotDetermined){
                        completion(NO,IBPrivacyAuthorizationNotDetermined);
                    }else if (status == EKAuthorizationStatusRestricted){
                        completion(NO,IBPrivacyAuthorizationRestricted);
                    }
                }
            }];
        } break;
            
        case IBPrivacyPermissionHealth:{
            HKHealthStore *store = [[HKHealthStore alloc] init];
            NSSet *readObjectTypes = [self readObjectTypes];
            NSSet *writeObjectTypes = [self writeObjectTypes];
            [store requestAuthorizationToShareTypes:writeObjectTypes readTypes:readObjectTypes completion:^(BOOL success, NSError * _Nullable error) {
                if (success == YES) {
                    completion(YES,IBPrivacyAuthorizationAuthorized);
                }else{
                    completion(NO,IBPrivacyAuthorizationUnkonwn);
                }
            }];
        } break;
            
        case IBPrivacyPermissionSiri:{
            if (@available(iOS 10.0, *)) {
                [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
                    if (status == INSiriAuthorizationStatusNotDetermined) {
                        completion(NO, IBPrivacyAuthorizationNotDetermined);
                    }
                    if (status == INSiriAuthorizationStatusRestricted) {
                        completion(NO, IBPrivacyAuthorizationRestricted);
                    }
                    if (status == INSiriAuthorizationStatusDenied) {
                        completion(NO, IBPrivacyAuthorizationDenied);
                    }
                    if (status == INSiriAuthorizationStatusAuthorized) {
                        completion(NO, IBPrivacyAuthorizationAuthorized);
                    }
                }];
            }
        } break;
            
        default:
            break;
    }
}

#pragma mark - Private
+ (NSSet *)readObjectTypes{
    HKQuantityType *StepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *DistanceWalkingRunning= [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKObjectType *FlightsClimbed = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    
    return [NSSet setWithObjects:StepCount,DistanceWalkingRunning,FlightsClimbed, nil];
}

 + (NSSet *)writeObjectTypes{
    HKQuantityType *StepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *DistanceWalkingRunning= [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKObjectType *FlightsClimbed = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    
    return [NSSet setWithObjects:StepCount,DistanceWalkingRunning,FlightsClimbed, nil];
}

@end


