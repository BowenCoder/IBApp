//
//  MBAsset.m
//  IBApplication
//
//  Created by Bowen on 2020/4/1.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import "MBAsset.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIMacros.h"

static NSString * const kAssetInfoImageData = @"imageData";
static NSString * const kAssetInfoOriginInfo = @"originInfo";
static NSString * const kAssetInfoDataUTI = @"dataUTI";
static NSString * const kAssetInfoOrientation = @"orientation";
static NSString * const kAssetInfoSize = @"size";

@interface MBAsset ()

@property (nonatomic, copy) NSDictionary *phAssetInfo;
@property (nonatomic, strong) PHAsset *phAsset;
@property (nonatomic, assign) CGFloat imageSize;

@end

@implementation MBAsset

- (instancetype)initWithPHAsset:(PHAsset *)phAsset {
    if (self = [super init]) {
        self.phAsset = phAsset;
        switch (phAsset.mediaType) {
            case PHAssetMediaTypeImage:
                _assetType = MBAssetTypeImage;
                if ([[phAsset valueForKey:@"uniformTypeIdentifier"] isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                    _assetSubType = MBAssetSubTypeGIF;
                } else {
                    if (@available(iOS 9.1, *)) {
                        if (phAsset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
                            _assetSubType = MBAssetSubTypeLivePhoto;
                        } else {
                            _assetSubType = MBAssetSubTypeImage;
                        }
                    } else {
                        _assetSubType = MBAssetSubTypeImage;
                    }
                }
                break;
            case PHAssetMediaTypeVideo:
                _assetType = MBAssetTypeVideo;
                break;
            case PHAssetMediaTypeAudio:
                _assetType = MBAssetTypeAudio;
                break;
            default:
                _assetType = MBAssetTypeUnknow;
                break;
        }
    }
    return self;
}

- (UIImage *)originImage {
    __block UIImage *resultImage = nil;
    PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
    phImageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    phImageRequestOptions.networkAccessAllowed = YES;
    phImageRequestOptions.synchronous = YES;
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:self.phAsset options:phImageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        resultImage = [UIImage imageWithData:imageData];
    }];
    return resultImage;
}

- (UIImage *)thumbnailWithSize:(CGSize)size {
    __block UIImage *resultImage;
    PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
    phImageRequestOptions.networkAccessAllowed = YES;
    phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
    [[PHCachingImageManager defaultManager] requestImageForAsset:self.phAsset
                                                      targetSize:CGSizeMake(size.width * kScreenScale, size.height * kScreenScale)
                                                     contentMode:PHImageContentModeAspectFill options:phImageRequestOptions
                                                   resultHandler:^(UIImage *result, NSDictionary *info) {
        resultImage = result;
    }];
    
    return resultImage;
}

- (UIImage *)previewImage {
    __block UIImage *resultImage = nil;
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.networkAccessAllowed = YES;
    imageRequestOptions.synchronous = YES;
    [[PHCachingImageManager defaultManager] requestImageForAsset:self.phAsset
                                                      targetSize:CGSizeMake(kScreenWidth, kScreenHeight)
                                                     contentMode:PHImageContentModeAspectFill
                                                         options:imageRequestOptions
                                                   resultHandler:^(UIImage *result, NSDictionary *info) {
        resultImage = result;
    }];
    return resultImage;
}

- (NSInteger)requestOriginImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
    imageRequestOptions.progressHandler = phProgressHandler;
    return [[PHCachingImageManager defaultManager] requestImageDataForAsset:self.phAsset options:imageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (completion) {
            completion([UIImage imageWithData:imageData], info);
        }
    }];
}

- (NSInteger)requestThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion {
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    imageRequestOptions.networkAccessAllowed = YES;
    // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
    return [[PHCachingImageManager defaultManager] requestImageForAsset:self.phAsset targetSize:CGSizeMake(size.width * kScreenScale, size.height * kScreenScale) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        if (completion) {
            completion(result, info);
        }
    }];
}

- (NSInteger)requestPreviewImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
    imageRequestOptions.progressHandler = phProgressHandler;
    return [[PHCachingImageManager defaultManager] requestImageForAsset:self.phAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        if (completion) {
            completion(result, info);
        }
    }];
}

- (NSInteger)requestLivePhotoWithCompletion:(void (^)(PHLivePhoto *livePhoto, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
    if ([[PHCachingImageManager class] instancesRespondToSelector:@selector(requestLivePhotoForAsset:targetSize:contentMode:options:resultHandler:)]) {
        PHLivePhotoRequestOptions *livePhotoRequestOptions = [[PHLivePhotoRequestOptions alloc] init];
        livePhotoRequestOptions.networkAccessAllowed = YES; // 允许访问网络
        livePhotoRequestOptions.progressHandler = phProgressHandler;
        return [[PHCachingImageManager defaultManager] requestLivePhotoForAsset:self.phAsset targetSize:CGSizeMake(kScreenWidth, kScreenHeight) contentMode:PHImageContentModeDefault options:livePhotoRequestOptions resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
            if (completion) {
                completion(livePhoto, info);
            }
        }];
    } else {
        if (completion) {
            completion(nil, nil);
        }
        return 0;
    }
}

- (NSInteger)requestPlayerItemWithCompletion:(void (^)(AVPlayerItem *playerItem, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetVideoProgressHandler)phProgressHandler {
    if ([[PHCachingImageManager class] instancesRespondToSelector:@selector(requestPlayerItemForVideo:options:resultHandler:)]) {
        PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
        videoRequestOptions.networkAccessAllowed = YES; // 允许访问网络
        videoRequestOptions.progressHandler = phProgressHandler;
        return [[PHCachingImageManager defaultManager] requestPlayerItemForVideo:self.phAsset options:videoRequestOptions resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            if (completion) {
                completion(playerItem, info);
            }
        }];
    } else {
        if (completion) {
            completion(nil, nil);
        }
        return 0;
    }
}

- (void)requestImageData:(void (^)(NSData *imageData, NSDictionary<NSString *, id> *info, BOOL isGIF, BOOL isHEIC))completion {
    if (self.assetType != MBAssetTypeImage) {
        if (completion) {
            completion(nil, nil, NO, NO);
        }
        return;
    }
    __weak __typeof(self)weakSelf = self;
    if (!self.phAssetInfo) {
        // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
        [self requestPhAssetInfo:^(NSDictionary *phAssetInfo) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.phAssetInfo = phAssetInfo;
            if (completion) {
                NSString *dataUTI = phAssetInfo[kAssetInfoDataUTI];
                BOOL isGIF = self.assetSubType == MBAssetSubTypeGIF;
                BOOL isHEIC = [dataUTI isEqualToString:@"public.heic"];
                NSDictionary<NSString *, id> *originInfo = phAssetInfo[kAssetInfoOriginInfo];
                completion(phAssetInfo[kAssetInfoImageData], originInfo, isGIF, isHEIC);
            }
        }];
    } else {
        if (completion) {
            NSString *dataUTI = self.phAssetInfo[kAssetInfoDataUTI];
            BOOL isGIF = self.assetSubType == MBAssetSubTypeGIF;
            BOOL isHEIC = [@"public.heic" isEqualToString:dataUTI];
            NSDictionary<NSString *, id> *originInfo = self.phAssetInfo[kAssetInfoOriginInfo];
            completion(self.phAssetInfo[kAssetInfoImageData], originInfo, isGIF, isHEIC);
        }
    }
}

- (UIImageOrientation)imageOrientation {
    UIImageOrientation orientation;
    if (self.assetType == MBAssetTypeImage) {
        if (!self.phAssetInfo) {
            // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
            __weak __typeof(self)weakSelf = self;
            [self requestImagePhAssetInfo:^(NSDictionary *phAssetInfo) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                strongSelf.phAssetInfo = phAssetInfo;
            } synchronous:YES];
        }
        // 从 PhAssetInfo 中获取 UIImageOrientation 对应的字段
        orientation = (UIImageOrientation)[self.phAssetInfo[kAssetInfoOrientation] integerValue];
    } else {
        orientation = UIImageOrientationUp;
    }
    return orientation;
}

- (NSString *)identifier {
    return self.phAsset.localIdentifier;
}

- (void)requestPhAssetInfo:(void (^)(NSDictionary *))completion {
    if (!self.phAsset) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    if (self.assetType == MBAssetTypeVideo) {
        PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
        videoRequestOptions.networkAccessAllowed = YES;
        [[PHCachingImageManager defaultManager] requestAVAssetForVideo:self.phAsset options:videoRequestOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                NSMutableDictionary *tempInfo = [[NSMutableDictionary alloc] init];
                if (info) {
                    [tempInfo setObject:info forKey:kAssetInfoOriginInfo];
                }
                AVURLAsset *urlAsset = (AVURLAsset*)asset;
                NSNumber *size;
                [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                [tempInfo setObject:size forKey:kAssetInfoSize];
                if (completion) {
                    completion(tempInfo);
                }
            }
        }];
    } else {
        [self requestImagePhAssetInfo:^(NSDictionary *phAssetInfo) {
            if (completion) {
                completion(phAssetInfo);
            }
        } synchronous:NO];
    }
}

- (void)requestImagePhAssetInfo:(void (^)(NSDictionary *))completion synchronous:(BOOL)synchronous {
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.synchronous = synchronous;
    imageRequestOptions.networkAccessAllowed = YES;
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:self.phAsset options:imageRequestOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (info) {
            NSMutableDictionary *tempInfo = [[NSMutableDictionary alloc] init];
            if (imageData) {
                [tempInfo setObject:imageData forKey:kAssetInfoImageData];
                [tempInfo setObject:@(imageData.length) forKey:kAssetInfoSize];
            }
            [tempInfo setObject:info forKey:kAssetInfoOriginInfo];
            if (dataUTI) {
                [tempInfo setObject:dataUTI forKey:kAssetInfoDataUTI];
            }
            [tempInfo setObject:@(orientation) forKey:kAssetInfoOrientation];
            if (completion) {
                completion(tempInfo);
            }
        }
    }];
}

- (void)setDownloadProgress:(double)downloadProgress {
    _downloadProgress = downloadProgress;
    _downloadStatus = MBAssetDownloadStatusDownloading;
}

- (void)updateDownloadStatusWithDownloadResult:(BOOL)succeed {
    _downloadStatus = succeed ? MBAssetDownloadStatusSucceed : MBAssetDownloadStatusFailed;
}

- (void)assetSize:(void (^)(long long size))completion {
    if (!self.phAssetInfo) {
        // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
        __weak __typeof(self)weakSelf = self;
        [self requestPhAssetInfo:^(NSDictionary *phAssetInfo) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.phAssetInfo = phAssetInfo;
            if (completion) {
                /**
                 *  这里不在主线程执行，若用户在该 block 中操作 UI 时会产生一些问题，
                 *  为了避免这种情况，这里该 block 主动放到主线程执行。
                 */
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion([phAssetInfo[kAssetInfoSize] longLongValue]);
                });
            }
        }];
    } else {
        if (completion) {
            completion([self.phAssetInfo[kAssetInfoSize] longLongValue]);
        }
    }
}

- (NSTimeInterval)duration {
    if (self.assetType != MBAssetTypeVideo) {
        return 0;
    }
    return self.phAsset.duration;
}

- (BOOL)isEqual:(id)object {
    if (!object) return NO;
    if (self == object) return YES;
    if (![object isKindOfClass:[self class]]) return NO;
    return [self.identifier isEqualToString:((MBAsset *)object).identifier];
}


@end
