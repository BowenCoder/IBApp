//
//  IBFile.h
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IBFile : NSObject

/// cache目录
+ (NSString *)cachePath;

/// library目录
+ (NSString *)libraryPath;

/// document目录
+ (NSString *)documentPath;

/// temporary目录
+ (NSString *)temporaryPath;

/// mainBundle目录
+ (NSString *)mainBundlePath;

/// homeDirectory目录
+ (NSString *)homeDirectoryPath;

/// applicationSupportPath目录
+ (NSString *)applicationSupportPath;

/// 获取在temporary目录下的文件路径
+ (NSString *)filePathInTemp:(NSString *)fileName;

/// 获取temporary目录下的文件夹路径(没有则创建)
+ (NSString *)filePathInTemp:(NSString *)fileName inDir:(NSString *)dirName;

/// 获取在Caches目录下的文件路径
+ (NSString *)filePathInCaches:(NSString *)fileName;

/// 获取Caches目录下的文件夹路径(没有则创建)
+ (NSString *)filePathInCaches:(NSString *)fileName inDir:(NSString *)dirName;

/// 获取Documents目录下的文件路径
+ (NSString *)filePathInDocuments:(NSString *)fileName;

/// 获取Documents目录下指定文件夹下的的文件路径
+ (NSString *)filePathInDocuments:(NSString *)fileName inDir:(NSString *)dirName;

/// 获取Resource目录下的文件路径
+ (NSString *)filePathInResource:(NSString *)fileName;

/// 获取Resource目录下指定文件下的文件路径
+ (NSString *)filePathInResource:(NSString *)fileName inDir:(NSString *)dirName;

/// 获取Library目录下的文件路径
+ (NSString *)filePathInLibrary:(NSString *)fileName;

/// 获取Library目录下指定文件下的文件路径
+ (NSString *)filePathInLibrary:(NSString *)fileName inDir:(NSString *)dirName;

/// 返回 Library/Data/xxx文件
+ (NSString *)filePathInDataDirInLibrary:(NSString *)fileName;

/// 返回 Library/User/xxx文件
+ (NSString *)filePathInUserDirInLibrary:(NSString *)fileName;

/// 返回 Tmp/xxx/
+ (NSString *)dirPathInTmp:(NSString *)dirName;

/// 返回Caches/xxx/
+ (NSString *)dirPathInCaches:(NSString *)dirName;

/// 返回 Documents/xxx/
+ (NSString *)dirPathInDocuments:(NSString *)dirName;

/// 返回 Library/xxx/
+ (NSString *)dirPathInLibrary:(NSString *)dirName;

+ (BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError **)error;

+ (BOOL)createDirForFileAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)createDirForPath:(NSString *)path error:(NSError **)error;

+ (BOOL)createFileAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite error:(NSError **)error;

+ (BOOL)createFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError **)error;

+ (BOOL)createFileAtPath:(NSString *)path content:(NSObject *)content overwrite:(BOOL)overwrite error:(NSError **)error;

+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;

+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;

+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;

+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;

+ (BOOL)removeFilesInDirAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)removeFilesInDirAtPath:(NSString *)path extension:(NSString *)extension error:(NSError **)error;

+ (BOOL)removeFilesInDirAtPath:(NSString *)path prefix:(NSString *)prefix error:(NSError **)error;

+ (BOOL)removeFilesInDirAtPath:(NSString *)path suffix:(NSString *)suffix error:(NSError **)error;

+ (BOOL)removeItemsInDirAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)renameItemAtPath:(NSString *)path name:(NSString *)name error:(NSError **)error;

+ (NSArray *)listDirAtPath:(NSString *)path;

+ (NSArray *)listDirAtPath:(NSString *)path deep:(BOOL)deep;

+ (NSArray *)listFilesInDirAtPath:(NSString *)path;

+ (NSArray *)listFilesInDirAtPath:(NSString *)path deep:(BOOL)deep;

+ (NSArray *)listFilesInDirAtPath:(NSString *)path extension:(NSString *)extension;

+ (NSArray *)listFilesInDirAtPath:(NSString *)path extension:(NSString *)extension deep:(BOOL)deep;

+ (NSArray *)listFilesInDirAtPath:(NSString *)path prefix:(NSString *)prefix;

+ (NSArray *)listFilesInDirAtPath:(NSString *)path prefix:(NSString *)prefix deep:(BOOL)deep;

+ (NSArray *)listFilesInDirAtPath:(NSString *)path suffix:(NSString *)suffix;

+ (NSArray *)listFilesInDirAtPath:(NSString *)path suffix:(NSString *)suffix deep:(BOOL)deep;

+ (NSArray *)listItemsInDirAtPath:(NSString *)path deep:(BOOL)deep;

+ (NSString *)readFileAtPathAsString:(NSString *)path error:(NSError **)error;

+ (NSString *)readFileAtPath:(NSString *)path error:(NSError **)error;

+ (NSArray *)readFileAtPathAsArray:(NSString *)path;

+ (NSObject *)readFileAtPathAsCustomModel:(NSString *)path;

+ (NSData *)readFileAtPathAsData:(NSString *)path error:(NSError **)error;

+ (NSDictionary *)readFileAtPathAsDictionary:(NSString *)path;

+ (UIImage *)readFileAtPathAsImage:(NSString *)path error:(NSError **)error;

+ (UIImageView *)readFileAtPathAsImageView:(NSString *)path error:(NSError **)error;

+ (NSJSONSerialization *)readFileAtPathAsJSON:(NSString *)path error:(NSError **)error;

+ (NSMutableArray *)readFileAtPathAsMutableArray:(NSString *)path;

+ (NSMutableData *)readFileAtPathAsMutableData:(NSString *)path error:(NSError **)error;

+ (NSMutableDictionary *)readFileAtPathAsMutableDictionary:(NSString *)path;

+ (NSString *)sizeFormatted:(NSNumber *)size;

+ (NSString *)sizeFormattedOfDirAtPath:(NSString *)path error:(NSError **)error;

+ (NSString *)sizeFormattedOfFileAtPath:(NSString *)path error:(NSError **)error;

+ (NSString *)sizeFormattedOfItemAtPath:(NSString *)path error:(NSError **)error;

+ (NSNumber *)sizeOfDirAtPath:(NSString *)path error:(NSError **)error;

+ (NSNumber *)sizeOfFileAtPath:(NSString *)path error:(NSError **)error;

+ (NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError **)error;

+ (NSDictionary *)metadataOfImageAtPath:(NSString *)path;

+ (NSDictionary *)exifDataOfImageAtPath:(NSString *)path;

+ (NSDictionary *)tiffDataOfImageAtPath:(NSString *)path;

+ (NSDictionary *)xattrOfItemAtPath:(NSString *)path;

+ (NSString *)xattrOfItemAtPath:(NSString *)path getValueForKey:(NSString *)key;

+ (BOOL)xattrOfItemAtPath:(NSString *)path hasValueForKey:(NSString *)key;

+ (BOOL)xattrOfItemAtPath:(NSString *)path removeValueForKey:(NSString *)key;

+ (BOOL)xattrOfItemAtPath:(NSString *)path setValue:(NSString *)value forKey:(NSString *)key;

+ (id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error;

+ (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error;

+ (NSDate *)creationDateOfItemAtPath:(NSString *)path error:(NSError **)error;

+ (NSDate *)modificationDateOfItemAtPath:(NSString *)path error:(NSError **)error;

+ (NSURL *)urlForItemAtPath:(NSString *)path;

+ (NSString *)pathForPlistNamed:(NSString *)name;

+ (BOOL)isExecutableItemAtPath:(NSString *)path;

+ (BOOL)isReadableItemAtPath:(NSString *)path;

+ (BOOL)isWritableItemAtPath:(NSString *)path;

+ (BOOL)emptyCachesPath;

+ (BOOL)emptyTemporaryPath;

+ (BOOL)isFileExists:(NSString *)path;

+ (BOOL)isDirExists:(NSString *)path;

+ (BOOL)isEmptyItemAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)isDirItemAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)isFileItemAtPath:(NSString *)path error:(NSError **)error;

@end
