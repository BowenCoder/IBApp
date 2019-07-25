//
//  IBFile.h
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IBFile : NSObject

+ (id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error;

+ (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)createDirForFileAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)createDirForPath:(NSString *)path error:(NSError **)error;

+ (BOOL)createFileAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite error:(NSError **)error;

+ (BOOL)createFileAtPath:(NSString *)path withContent:(NSObject *)content error:(NSError **)error;

+ (BOOL)createFileAtPath:(NSString *)path withContent:(NSObject *)content overwrite:(BOOL)overwrite error:(NSError **)error;

+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;

+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;

+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;

+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;

+ (BOOL)removeFilesInDirAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)removeFilesInDirAtPath:(NSString *)path withExtension:(NSString *)extension error:(NSError **)error;

+ (BOOL)removeFilesInDirAtPath:(NSString *)path withPrefix:(NSString *)prefix error:(NSError **)error;

+ (BOOL)removeFilesInDirAtPath:(NSString *)path withSuffix:(NSString *)suffix error:(NSError **)error;

+ (BOOL)removeItemsInDirAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)renameItemAtPath:(NSString *)path withName:(NSString *)name error:(NSError **)error;

+ (NSDate *)creationDateOfItemAtPath:(NSString *)path error:(NSError **)error;

+ (NSDate *)modificationDateOfItemAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)emptyCachesDir;
+ (BOOL)emptyTemporaryDir;

+ (BOOL)existsItemAtPath:(NSString *)path;

+ (BOOL)isDirItemAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)isEmptyItemAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)isFileItemAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)isExecutableItemAtPath:(NSString *)path;
+ (BOOL)isReadableItemAtPath:(NSString *)path;
+ (BOOL)isWritableItemAtPath:(NSString *)path;

+ (NSArray *)listDirAtPath:(NSString *)path;
+ (NSArray *)listDirAtPath:(NSString *)path deep:(BOOL)deep;

+ (NSArray *)listFilesInDirAtPath:(NSString *)path;
+ (NSArray *)listFilesInDirAtPath:(NSString *)path deep:(BOOL)deep;

+ (NSArray *)listFilesInDirAtPath:(NSString *)path withExtension:(NSString *)extension;
+ (NSArray *)listFilesInDirAtPath:(NSString *)path withExtension:(NSString *)extension deep:(BOOL)deep;

+ (NSArray *)listFilesInDirAtPath:(NSString *)path withPrefix:(NSString *)prefix;
+ (NSArray *)listFilesInDirAtPath:(NSString *)path withPrefix:(NSString *)prefix deep:(BOOL)deep;

+ (NSArray *)listFilesInDirAtPath:(NSString *)path withSuffix:(NSString *)suffix;
+ (NSArray *)listFilesInDirAtPath:(NSString *)path withSuffix:(NSString *)suffix deep:(BOOL)deep;

+ (NSArray *)listItemsInDirAtPath:(NSString *)path deep:(BOOL)deep;

+ (NSString *)pathForApplicationSupportDir;
+ (NSString *)pathForApplicationSupportDirWithPath:(NSString *)path;

+ (NSString *)pathForCachesDir;
+ (NSString *)pathForCachesDirWithPath:(NSString *)path;

+ (NSString *)pathForDocumentsDir;
+ (NSString *)pathForDocumentsDirWithPath:(NSString *)path;

+ (NSString *)pathForLibraryDir;
+ (NSString *)pathForLibraryDirWithPath:(NSString *)path;

+ (NSString *)pathForMainBundleDir;
+ (NSString *)pathForMainBundleDirWithPath:(NSString *)path;

+ (NSString *)pathForTemporaryDir;
+ (NSString *)pathForTemporaryDirWithPath:(NSString *)path;

+ (NSString *)pathForPlistNamed:(NSString *)name;

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

+ (NSURL *)urlForItemAtPath:(NSString *)path;

+ (BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError **)error;

+ (NSDictionary *)metadataOfImageAtPath:(NSString *)path;
+ (NSDictionary *)exifDataOfImageAtPath:(NSString *)path;
+ (NSDictionary *)tiffDataOfImageAtPath:(NSString *)path;

+ (NSDictionary *)xattrOfItemAtPath:(NSString *)path;
+ (NSString *)xattrOfItemAtPath:(NSString *)path getValueForKey:(NSString *)key;
+ (BOOL)xattrOfItemAtPath:(NSString *)path hasValueForKey:(NSString *)key;
+ (BOOL)xattrOfItemAtPath:(NSString *)path removeValueForKey:(NSString *)key;
+ (BOOL)xattrOfItemAtPath:(NSString *)path setValue:(NSString *)value forKey:(NSString *)key;

@end
