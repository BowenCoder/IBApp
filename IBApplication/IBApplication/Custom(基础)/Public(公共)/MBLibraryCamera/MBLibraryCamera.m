//
//  MBLibraryCamera.m
//  IBApplication
//
//  Created by BowenCoder on 2019/6/1.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBLibraryCamera.h"
#import "RSKImageCropViewController.h"
#import "IBImage.h"
#import "UIMacros.h"

@interface MBLibraryCamera () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource>

@property (nonatomic, weak) UIViewController *currentController;

@end

@implementation MBLibraryCamera

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allowsEditing = YES;
    }
    return self;
}

- (UIImagePickerController *)imagePickerController
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.navigationBar.barTintColor = [UIColor whiteColor];
    picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    picker.delegate = self;
    return picker;
}

#pragma mark - 摄像头和相册相关的公共类
// 判断设备是否有摄像头
- (BOOL)isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// 前面的摄像头是否可用
- (BOOL)isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

// 后面的摄像头是否可用
- (BOOL)isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

/** 打开相机 */
- (void)openCamera:(UIViewController *)viewController{
    if (![self isCameraAvailable]) {
        [self showAlertViewTitle:@"温馨提示" message:@"相机不可用" viewController:viewController];
        return;
    }
    self.currentController = viewController;
    UIImagePickerController *pickerController = [self imagePickerController];
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
        [self showAlertViewTitle:@"本软件没有相机访问权限" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" viewController:viewController];
        return;
    }
    if (status == AVAuthorizationStatusNotDetermined) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    [viewController presentViewController:pickerController animated:YES completion:nil];
                }
            }];
        });
        return;
    }
    [viewController presentViewController:pickerController animated:YES completion:nil];
}


/** 打开相册 */
- (void)openGallery:(UIViewController *)viewController{

    self.currentController = viewController;
    UIImagePickerController *pickerController = [self imagePickerController];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        [self showAlertViewTitle:@"本软件没有相册访问权限" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" viewController:viewController];
        return;
    }
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    [viewController presentViewController:pickerController animated:YES completion:nil];
                }
            });
        }];
        return;
    }
    
    //打开相册
    [viewController presentViewController:pickerController animated:YES completion:nil];
}

- (void)showAlertViewTitle:(NSString *)titleStr message:(NSString *)message viewController:(UIViewController *)viewController{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleStr message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction: [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }]];
    //显示
    [viewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - RSKImageCropViewController

- (void)showImageCropViewControllerWithImage:(UIImage *)image controller:(UIImagePickerController *)picker
{
    RSKImageCropViewController *crop = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCustom];
    crop.delegate = self;
    crop.dataSource = self;
    crop.moveAndScaleLabel.hidden = YES;
    crop.avoidEmptySpaceAroundImage = YES;
    crop.maskLayerLineWidth = 1;
    crop.maskLayerStrokeColor = [UIColor whiteColor];
    [picker dismissViewControllerAnimated:NO completion:nil];
    [self.currentController presentViewController:crop animated:YES completion:nil];
}

#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel)]) {
        [self.delegate imagePickerControllerDidCancel];
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect rotationAngle:(CGFloat)rotationAngle
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissImagePickerControllerWithImage:)]) {
        [self.delegate dismissImagePickerControllerWithImage:croppedImage];
    }
    [controller dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - RSKImageCropViewControllerDataSource

- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller
{
    CGFloat space = 28;
    CGFloat top = kIphoneX ? 64 : 44;
    CGFloat bottom = kIphoneX ? 94 : 70;
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat width = screenRect.size.width - space * 2;
    CGFloat height = width;
    top = top + (screenRect.size.height - top - bottom - height) * 0.5;
    CGRect rect = CGRectMake(space, top, width, height);
    return rect;
}

- (UIBezierPath *)imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller
{
    CGRect rect = controller.maskRect;
    CGPoint point1 = rect.origin;
    CGPoint point2 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    CGPoint point3 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGPoint point4 = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint:point1];
    [triangle addLineToPoint:point2];
    [triangle addLineToPoint:point3];
    [triangle addLineToPoint:point4];
    [triangle closePath];
    
    return triangle;
}

- (CGRect)imageCropViewControllerCustomMovementRect:(RSKImageCropViewController *)controller
{
    return controller.maskRect;
}

#pragma mark - UIImagePickerControllerDelegate

/** 选取图片后执行方法 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [IBImage fixOrientation:image];
    if (self.allowsEditing && image) {
        [self showImageCropViewControllerWithImage:image controller:picker];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dismissImagePickerControllerWithImage:)]) {
            [self.delegate dismissImagePickerControllerWithImage:image];
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

/** 点击取消执行方法 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel)]) {
        [self.delegate imagePickerControllerDidCancel];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 保存图片至沙盒

- (NSData *)imageData:(UIImage *)image{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if (data.length>100*1024) {
        if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(image, 0.1);
        } else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(image, 0.5);
        } else if (data.length>200*1024) {//0.25M-0.5M
            data=UIImageJPEGRepresentation(image, 0.9);
        }
    }
    return data;
}


@end
