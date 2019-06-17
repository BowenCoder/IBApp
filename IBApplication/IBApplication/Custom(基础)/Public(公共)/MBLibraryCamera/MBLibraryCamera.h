//
//  MBLibraryCamera.h
//  IBApplication
//
//  Created by BowenCoder on 2019/6/1.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
//导入相册库 iOS7
#import <AssetsLibrary/AssetsLibrary.h>
//导入相册库 iOS8
#import <Photos/Photos.h>
//导入相机框架
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MBLibraryCameraDelegate <NSObject>

//消失界面
-(void)dismissImagePickerControllerWithImage:(UIImage *)image;
@optional
//选择界面取消按钮点击
-(void)imagePickerControllerDidCancel;

@end

@interface MBLibraryCamera : NSObject

@property (nonatomic, weak) id<MBLibraryCameraDelegate> delegate;

/** 图片是否编辑,默认yes */
@property (nonatomic,assign) BOOL allowsEditing;

/** 打开相册 */
-(void)openGallery:(UIViewController *)viewController;

/** 打开相机 */
-(void)openCamera:(UIViewController *)viewController;


/** 判断设备是否有摄像头 */
-(BOOL)isCameraAvailable;

/** 前面的摄像头是否可用 */
-(BOOL)isFrontCameraAvailable;

/** 后面的摄像头是否可用 */
-(BOOL)isRearCameraAvailable;


@end

NS_ASSUME_NONNULL_END
