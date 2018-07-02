/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com"
 * (c) Florent Vilmart
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageCompat.h"

#if SD_UIKIT
#import <UIKit/UIKit.h>
#endif

//! Project version number for WebImage.
FOUNDATION_EXPORT double WebImageVersionNumber;

//! Project version string for WebImage.
FOUNDATION_EXPORT const unsigned char WebImageVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <WebImage/PublicHeader.h"

#import "SDWebImageManager.h"
#import "SDImageCacheConfig.h"
#import "SDImageCache.h"
#import "UIView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+HighlightedWebCache.h"
#import "SDWebImageDownloaderOperation.h"
#import "UIButton+WebCache.h"
#import "SDWebImagePrefetcher.h"
#import "UIView+WebCacheOperation.h"
#import "UIImage+MultiFormat.h"
#import "SDWebImageOperation.h"
#import "SDWebImageDownloader.h"
#import "SDWebImageTransition.h"

#if SD_MAC || SD_UIKIT
    #import "MKAnnotationView+WebCache.h"
#endif

#import "SDWebImageCodersManager.h"
#import "SDWebImageCoder.h"
#import "SDWebImageWebPCoder.h"
#import "SDWebImageGIFCoder.h"
#import "SDWebImageImageIOCoder.h"
#import "SDWebImageFrame.h"
#import "SDWebImageCoderHelper.h"
#import "UIImage+WebP.h"
#import "UIImage+GIF.h"
#import "UIImage+ForceDecode.h"
#import "NSData+ImageContentType.h"

#if SD_MAC
    #import "NSImage+WebCache.h"
    #import "NSButton+WebCache.h"
    #import "SDAnimatedImageRep.h"
#endif

#if SD_UIKIT
    #import "FLAnimatedImageView+WebCache.h"

    #if __has_include("FLAnimatedImage.h")
        #import "FLAnimatedImage.h"
    #endif

    #if __has_include("FLAnimatedImageView.h")
        #import "FLAnimatedImageView.h"
    #endif

#endif
