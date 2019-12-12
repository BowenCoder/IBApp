//
//  IBNetApiKeyInner.m
//  IBApplication
//
//  Created by Bowen on 2019/12/12.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBNetApiKeyInner.h"

@implementation IBNetApiKeyInner

#ifdef DEBUG

NSString * const kNETBaseUrl = @"http://192.168.20.31:20000/shark-miai-service";

#elif defined PRODUCT

NSString * const kNETBaseUrl = @"http://192.168.11.11:8080/shark-miai-service";

#else

NSString * const kNETBaseUrl = @"http://192.168.11.11:8080/shark-miai-service";

#endif

NSString * const kNETUserAccountToken = @"USER_ACCOUNT_TOKEN";
NSString * const kNETImageUpload = @"IMAGE_UPLOAD";
NSString * const kNETVoiceUpload = @"VOICE_UPLOAD";
NSString * const kNETImagePrefixUrl = @"IMAGE";
NSString * const kNETImageScaleUrl  = @"IMAGE_SCALE";
NSString * const kNETVoiceDownloadUrl = @"VOICE_DOWNLOAD";
NSString * const kNETVideoDownloadUrl = @"VIDEO_DOWNLOAD";


@end
