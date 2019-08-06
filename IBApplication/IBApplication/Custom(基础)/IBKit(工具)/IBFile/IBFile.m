//
//  IBFile.m
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBFile.h"
#import <sys/xattr.h>

@implementation IBFile

+ (NSString *)cachePath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];;
}

+ (NSString *)libraryPath
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)documentPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
}

+ (NSString *)temporaryPath
{
    return NSTemporaryDirectory();
}

+ (NSString *)mainBundlePath
{
    return [NSBundle mainBundle].resourcePath;
}

+ (NSString *)homeDirectoryPath
{
    return NSHomeDirectory();
}

+ (NSString *)applicationSupportPath
{
    return [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)filePathInTemp:(NSString *)fileName
{
    return [[self temporaryPath] stringByAppendingPathComponent:fileName];
}

+ (NSString *)filePathInTemp:(NSString *)fileName inDir:(NSString *)dirName
{
    return [[self dirPathInTmp:dirName] stringByAppendingPathComponent:fileName];
}

+ (NSString *)filePathInCaches:(NSString *)filename
{
    return [[self cachePath] stringByAppendingPathComponent:filename];
}

+ (NSString *)filePathInCaches:(NSString *)filename inDir:(NSString *)dir
{
    return [[self dirPathInCaches:dir] stringByAppendingPathComponent:filename];
}

+ (NSString *)filePathInDocuments:(NSString *)filename
{
    return [[self documentPath] stringByAppendingPathComponent:filename];
}

+ (NSString *)filePathInDocuments:(NSString *)filename inDir:(NSString *)dir
{
    return [[self dirPathInDocuments:dir] stringByAppendingPathComponent:filename];
}

+ (NSString *)filePathInResource:(NSString *)name
{
    return [[self mainBundlePath] stringByAppendingPathComponent:name];
}

+ (NSString *)filePathInResource:(NSString *)name inDir:(NSString *)dir
{
    return [[[self mainBundlePath] stringByAppendingPathComponent:dir] stringByAppendingPathComponent:name];
}

+ (NSString *)filePathInLibrary:(NSString *)filename
{
    return [[self libraryPath] stringByAppendingPathComponent:filename];
}

+ (NSString *)filePathInLibrary:(NSString *)filename inDir:(NSString *)dir
{
    return [[self dirPathInLibrary:dir] stringByAppendingPathComponent:filename];
}

+ (NSString *)filePathInDataDirInLibrary:(NSString *)file
{
    return [self filePathInLibrary:file inDir:@"Data"];
}

+ (NSString *)filePathInUserDirInLibrary:(NSString *)file
{
    return [self filePathInLibrary:file inDir:@"User"];
}

+ (NSString *)dirPathInDocuments:(NSString *)dir
{
    NSError *error;
    NSString *path = [[self documentPath] stringByAppendingPathComponent:dir];
    if ([self createDirForPath:path error:&error]) {
        [self addSkipBackupAttributeToItemAtPath:path];
    }
    return path;
}

+ (NSString *)dirPathInLibrary:(NSString *)dir
{
    NSError *error;
    NSString *path = [[self libraryPath] stringByAppendingPathComponent:dir];
    if ([self createDirForPath:path error:&error]) {
        [self addSkipBackupAttributeToItemAtPath:path];
    }
    
    return path;
}

+ (NSString *)dirPathInCaches:(NSString *)dir
{
    NSError *error;
    NSString *path = [[self cachePath] stringByAppendingPathComponent:dir];
    if ([self createDirForPath:path error:&error]) {
        [self addSkipBackupAttributeToItemAtPath:path];
    }
    
    return path;
}

+ (NSString *)dirPathInTmp:(NSString *)dir
{
    NSError *error;
    NSString *path = [[self temporaryPath] stringByAppendingPathComponent:dir];
    if ([self createDirForPath:path error:&error]) {
        [self addSkipBackupAttributeToItemAtPath:path];
    }
    return path;
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString
{
    NSURL *URL = [NSURL fileURLWithPath:filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
    if (!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

+ (BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError **)error
{
    if (content == nil) {
        
        [NSException raise:@"Invalid content" format:@"content can't be nil."];
    }
    
    [self createFileAtPath:path content:nil overwrite:YES error:error];
    
    if ([content isKindOfClass:[NSMutableArray class]]) {
        
        [((NSMutableArray *)content) writeToFile:path atomically:YES];
        
    } else if ([content isKindOfClass:[NSArray class]]) {
        
        [((NSArray *)content) writeToFile:path atomically:YES];
        
    } else if ([content isKindOfClass:[NSMutableData class]]) {
        
        [((NSMutableData *)content) writeToFile:path atomically:YES];
        
    } else if ([content isKindOfClass:[NSData class]]) {
        
        [((NSData *)content) writeToFile:path atomically:YES];
        
    } else if ([content isKindOfClass:[NSMutableDictionary class]]) {
        
        [((NSMutableDictionary *)content) writeToFile:path atomically:YES];
        
    } else if ([content isKindOfClass:[NSDictionary class]]) {
        
        [((NSDictionary *)content) writeToFile:path atomically:YES];
        
    } else if ([content isKindOfClass:[NSJSONSerialization class]]) {
        
        [((NSDictionary *)content) writeToFile:path atomically:YES];
        
    } else if ([content isKindOfClass:[NSMutableString class]]) {
        
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        
    } else if ([content isKindOfClass:[NSString class]]) {
        
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        
    } else if ([content isKindOfClass:[UIImage class]]) {
        
        [UIImagePNGRepresentation((UIImage *)content) writeToFile:path atomically:YES];
        
    } else if ([content isKindOfClass:[UIImageView class]]) {
        
        return [self writeFileAtPath:path content:((UIImageView *)content).image error:error];
        
    } else if ([content conformsToProtocol:@protocol(NSCoding)]) {
        
        [NSKeyedArchiver archiveRootObject:content toFile:path];
        
    } else {
        [NSException raise:@"Invalid content type" format:@"content of type %@ is not handled.", NSStringFromClass([content class])];
        
        return NO;
    }
    
    return YES;
}

+ (BOOL)createDirForFileAtPath:(NSString *)path error:(NSError **)error
{
    NSString *pathLastChar = [path substringFromIndex:(path.length - 1)];
    
    if ([pathLastChar isEqualToString:@"/"]) {
        [NSException raise:@"Invalid path" format:@"file path can't have a trailing '/'."];
        return NO;
    }
    
    return [self createDirForPath:[path stringByDeletingLastPathComponent] error:error];
}

+ (BOOL)createDirForPath:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path error:(NSError **)error
{
    return [self createFileAtPath:path content:nil overwrite:NO error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite error:(NSError **)error
{
    return [self createFileAtPath:path content:nil overwrite:overwrite error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError **)error
{
    return [self createFileAtPath:path content:content overwrite:NO error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path content:(NSObject *)content overwrite:(BOOL)overwrite error:(NSError **)error
{
    if (![self isFileExists:path] ||
       (overwrite && [self removeItemAtPath:path error:error] && [self isNotError:error])) {
        
        if ([self createDirForFileAtPath:path error:error]) {
            BOOL created = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
            if (content != nil) {
                [self writeFileAtPath:path content:content error:error];
            }
            return (created && [self isNotError:error]);
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error
{
    return [self copyItemAtPath:path toPath:toPath overwrite:NO error:error];
}

+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error
{
    if (![self isFileExists:toPath] ||
        (overwrite && [self removeItemAtPath:toPath error:error] && [self isNotError:error])) {
        if ([self createDirForFileAtPath:toPath error:error]) {
            BOOL copied = [[NSFileManager defaultManager] copyItemAtPath:path toPath:path error:error];
            return (copied && [self isNotError:error]);
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error
{
    return [self moveItemAtPath:path toPath:toPath overwrite:NO error:error];
}

+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error
{
    if (![self isFileExists:toPath] ||
       (overwrite && [self removeItemAtPath:toPath error:error] && [self isNotError:error])) {
        
        return ([self createDirForFileAtPath:toPath error:error] && [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:error]);
    } else {
        return NO;
    }
}

+ (BOOL)removeFilesInDirAtPath:(NSString *)path error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDirAtPath:path] error:error];
}

+ (BOOL)removeFilesInDirAtPath:(NSString *)path extension:(NSString *)extension error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDirAtPath:path extension:extension] error:error];
}

+ (BOOL)removeFilesInDirAtPath:(NSString *)path prefix:(NSString *)prefix error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDirAtPath:path prefix:prefix] error:error];
}

+ (BOOL)removeFilesInDirAtPath:(NSString *)path suffix:(NSString *)suffix error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDirAtPath:path suffix:suffix] error:error];
}

+ (BOOL)removeItemsInDirAtPath:(NSString *)path error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listItemsInDirAtPath:path deep:NO] error:error];
}

+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

+ (BOOL)removeItemsAtPaths:(NSArray *)paths error:(NSError **)error
{
    BOOL success = YES;
    
    for(NSString *path in paths) {
        success &= [self removeItemAtPath:path error:error];
    }
    return success;
}

+ (BOOL)renameItemAtPath:(NSString *)path name:(NSString *)name error:(NSError **)error
{
    NSRange indexOfSlash = [name rangeOfString:@"/"];
    
    if (indexOfSlash.location < name.length) {
        
        [NSException raise:@"Invalid name" format:@"file name can't contain a '/'."];
        return NO;
    }
    
    return [self moveItemAtPath:path toPath:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:name] error:error];
}

+ (NSArray *)listDirAtPath:(NSString *)path
{
    return [self listDirAtPath:path deep:NO];
}

+ (NSArray *)listDirAtPath:(NSString *)path deep:(BOOL)deep
{
    NSArray *subpaths = [self listItemsInDirAtPath:path deep:deep];
    NSPredicate *predicate = [NSPredicate predicateWithBlock: ^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString *subpath = (NSString *)evaluatedObject;
        return [self isDirItemAtPath:subpath error:nil];
    }];
    return [subpaths filteredArrayUsingPredicate:predicate];
}

+ (NSArray *)listFilesInDirAtPath:(NSString *)path
{
    return [self listFilesInDirAtPath:path deep:NO];
}

+ (NSArray *)listFilesInDirAtPath:(NSString *)path deep:(BOOL)deep
{
    NSArray *subpaths = [self listItemsInDirAtPath:path deep:deep];
    
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:
                                                  ^BOOL(id evaluatedObject, NSDictionary *bindings) {
                                                      NSString *subpath = (NSString *)evaluatedObject;
                                                      return [self isFileItemAtPath:subpath error:nil];
                                                  }]];
}

+ (NSArray *)listFilesInDirAtPath:(NSString *)path extension:(NSString *)extension
{
    return [self listFilesInDirAtPath:path extension:extension deep:NO];
}

+ (NSArray *)listFilesInDirAtPath:(NSString *)path extension:(NSString *)extension deep:(BOOL)deep
{
    NSArray *subpaths = [self listFilesInDirAtPath:path deep:deep];
    
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        NSString *subpathExtension = [[subpath pathExtension] lowercaseString];
        NSString *filterExtension = [[extension lowercaseString] stringByReplacingOccurrencesOfString:@"." withString:@""];
        
        return [subpathExtension isEqualToString:filterExtension];
    }]];
}

+ (NSArray *)listFilesInDirAtPath:(NSString *)path prefix:(NSString *)prefix
{
    return [self listFilesInDirAtPath:path prefix:prefix deep:NO];
}

+ (NSArray *)listFilesInDirAtPath:(NSString *)path prefix:(NSString *)prefix deep:(BOOL)deep
{
    NSArray *subpaths = [self listFilesInDirAtPath:path deep:deep];
    
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        NSString *fileName = [subpath lastPathComponent];
        
        return ([fileName hasPrefix:prefix] || [fileName isEqualToString:prefix]);
    }]];
}

+ (NSArray *)listFilesInDirAtPath:(NSString *)path suffix:(NSString *)suffix
{
    return [self listFilesInDirAtPath:path suffix:suffix deep:NO];
}

+ (NSArray *)listFilesInDirAtPath:(NSString *)path suffix:(NSString *)suffix deep:(BOOL)deep
{
    NSArray *subpaths = [self listFilesInDirAtPath:path deep:deep];
    
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        NSString *subpathName = [subpath stringByDeletingPathExtension];
        
        return ([subpath hasSuffix:suffix] || [subpath isEqualToString:suffix] || [subpathName hasSuffix:suffix] || [subpathName isEqualToString:suffix]);
    }]];
}

+ (NSArray *)listItemsInDirAtPath:(NSString *)path deep:(BOOL)deep
{
    NSString *absolutePath = path;
    NSArray *relativeSubpaths = (deep ? [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:absolutePath error:nil] : [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absolutePath error:nil]);
    
    NSMutableArray *absoluteSubpaths = [[NSMutableArray alloc] init];
    
    for(NSString *relativeSubpath in relativeSubpaths) {
        
        NSString *absoluteSubpath = [absolutePath stringByAppendingPathComponent:relativeSubpath];
        [absoluteSubpaths addObject:absoluteSubpath];
    }
    
    return [NSArray arrayWithArray:absoluteSubpaths];
}

+ (NSString *)readFileAtPath:(NSString *)path error:(NSError **)error
{
    return [self readFileAtPathAsString:path error:error];
}

+ (NSArray *)readFileAtPathAsArray:(NSString *)path
{
    return [NSArray arrayWithContentsOfFile:path];
}

+ (NSObject *)readFileAtPathAsCustomModel:(NSString *)path
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

+ (NSData *)readFileAtPathAsData:(NSString *)path error:(NSError **)error
{
    return [NSData dataWithContentsOfFile:path options:NSDataReadingMapped error:error];
}

+ (NSDictionary *)readFileAtPathAsDictionary:(NSString *)path
{
    return [NSDictionary dictionaryWithContentsOfFile:path];
}

+ (UIImage *)readFileAtPathAsImage:(NSString *)path error:(NSError **)error
{
    NSData *data = [self readFileAtPathAsData:path error:error];
    
    if ([self isNotError:error]) {
        return [UIImage imageWithData:data];
    }
    
    return nil;
}

+ (UIImageView *)readFileAtPathAsImageView:(NSString *)path error:(NSError **)error
{
    UIImage *image = [self readFileAtPathAsImage:path error:error];
    
    if ([self isNotError:error]) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView sizeToFit];
        return imageView;
    }
    return nil;
}

+ (NSJSONSerialization *)readFileAtPathAsJSON:(NSString *)path error:(NSError **)error
{
    NSData *data = [self readFileAtPathAsData:path error:error];
    
    if ([self isNotError:error]) {
        
        NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
        if ([NSJSONSerialization isValidJSONObject:json]) {
            return json;
        }
    }
    return nil;
}

+ (NSMutableArray *)readFileAtPathAsMutableArray:(NSString *)path
{
    return [NSMutableArray arrayWithContentsOfFile:path];
}

+ (NSMutableData *)readFileAtPathAsMutableData:(NSString *)path error:(NSError **)error
{
    return [NSMutableData dataWithContentsOfFile:path options:NSDataReadingMapped error:error];
}

+ (NSMutableDictionary *)readFileAtPathAsMutableDictionary:(NSString *)path
{
    return [NSMutableDictionary dictionaryWithContentsOfFile:path];
}

+ (NSString *)readFileAtPathAsString:(NSString *)path error:(NSError **)error
{
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:error];
}

+ (NSString *)sizeFormatted:(NSNumber *)size
{
    //TODO if OS X 10.8 or iOS 6
    //return [NSByteCountFormatter stringFromByteCount:[size intValue] countStyle:NSByteCountFormatterCountStyleFile];
    
    double convertedValue = [size doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = @[@"bytes", @"KB", @"MB", @"GB", @"TB"];
    
    while(convertedValue > 1024){
        
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    NSString *sizeFormat = ((multiplyFactor > 1) ? @"%4.2f %@" : @"%4.0f %@");
    
    return [NSString stringWithFormat:sizeFormat, convertedValue, tokens[multiplyFactor]];
}

+ (NSString *)sizeFormattedOfDirAtPath:(NSString *)path error:(NSError **)error
{
    NSNumber *size = [self sizeOfDirAtPath:path error:error];
    
    if (size != nil && [self isNotError:error]) {
        
        return [self sizeFormatted:size];
    }
    return nil;
}

+ (NSString *)sizeFormattedOfFileAtPath:(NSString *)path error:(NSError **)error
{
    NSNumber *size = [self sizeOfFileAtPath:path error:error];
    
    if (size != nil && [self isNotError:error]) {
        
        return [self sizeFormatted:size];
    }
    
    return nil;
}

+ (NSString *)sizeFormattedOfItemAtPath:(NSString *)path error:(NSError **)error
{
    NSNumber *size = [self sizeOfItemAtPath:path error:error];
    
    if (size != nil && [self isNotError:error]) {
        
        return [self sizeFormatted:size];
    }
    return nil;
}

+ (NSNumber *)sizeOfDirAtPath:(NSString *)path error:(NSError **)error
{
    if ([self isDirItemAtPath:path error:error])
    {
        if ([self isNotError:error]) {
            
            NSNumber *size = [self sizeOfItemAtPath:path error:error];
            double sizeValue = [size doubleValue];
            
            if ([self isNotError:error]) {
                
                NSArray *subpaths = [self listItemsInDirAtPath:path deep:YES];
                NSUInteger subpathsCount = [subpaths count];
                
                for(NSUInteger i = 0; i < subpathsCount; i++) {
                    
                    NSString *subpath = [subpaths objectAtIndex:i];
                    NSNumber *subpathSize = [self sizeOfItemAtPath:subpath error:error];
                    
                    if ([self isNotError:error]) {
                        
                        sizeValue += [subpathSize doubleValue];
                    } else {
                        return nil;
                    }
                }
                return [NSNumber numberWithDouble:sizeValue];
            }
        }
    }
    return nil;
}

+ (NSNumber *)sizeOfFileAtPath:(NSString *)path error:(NSError **)error
{
    if ([self isFileItemAtPath:path error:error]) {
        
        if ([self isNotError:error]) {
            
            return [self sizeOfItemAtPath:path error:error];
        }
    }
    return nil;
}

+ (NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError **)error
{
    return (NSNumber *)[self attributeOfItemAtPath:path forKey:NSFileSize error:error];
}

+ (NSDictionary *)metadataOfImageAtPath:(NSString *)path
{
    if ([self isFileItemAtPath:path error:nil]) {
        
        // http://blog.depicus.com/getting-exif-data-from-images-on-ios/
        NSURL *url = [self urlForItemAtPath:path];
        CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
        NSDictionary *metadata = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, NULL));
        
        return metadata;
    }
    
    return nil;
}

+ (NSDictionary *)exifDataOfImageAtPath:(NSString *)path
{
    NSDictionary *metadata = [self metadataOfImageAtPath:path];
    
    if (metadata) {
        
        return [metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    }
    return nil;
}

+ (NSDictionary *)tiffDataOfImageAtPath:(NSString *)path
{
    NSDictionary *metadata = [self metadataOfImageAtPath:path];
    
    if (metadata) {
        return [metadata objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
    }
    return nil;
}

+ (NSDictionary *)xattrOfItemAtPath:(NSString *)path
{
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    
    const char *upath = [path UTF8String];
    
    ssize_t ukeysSize = listxattr(upath, NULL, 0, 0);
    
    if ( ukeysSize > 0 ) {
        
        char *ukeys = malloc(ukeysSize);
        
        ukeysSize = listxattr(upath, ukeys, ukeysSize, 0);
        
        NSUInteger keyOffset = 0;
        NSString *key;
        NSString *value;
        
        while(keyOffset < ukeysSize) {
            
            key = [NSString stringWithUTF8String:(keyOffset + ukeys)];
            keyOffset += ([key length] + 1);
            
            value = [self xattrOfItemAtPath:path getValueForKey:key];
            [values setObject:value forKey:key];
        }
        free(ukeys);
    }
    return [NSDictionary dictionaryWithObjects:[values allValues] forKeys:[values allKeys]];
}

+ (NSString *)xattrOfItemAtPath:(NSString *)path getValueForKey:(NSString *)key
{
    NSString *value = nil;
    
    const char *ukey = [key UTF8String];
    const char *upath = [path UTF8String];
    
    ssize_t uvalueSize = getxattr(upath, ukey, NULL, 0, 0, 0);
    
    if ( uvalueSize > -1 ) {
        
        if ( uvalueSize == 0 ) {
            
            value = @"";
        } else {
            
            char *uvalue = malloc(uvalueSize);
            if ( uvalue ) {
                getxattr(upath, ukey, uvalue, uvalueSize, 0, 0);
                uvalue[uvalueSize] = '\0';
                value = [NSString stringWithUTF8String:uvalue];
                free(uvalue);
            }
        }
    }
    return value;
}

+ (BOOL)xattrOfItemAtPath:(NSString *)path hasValueForKey:(NSString *)key
{
    return ([self xattrOfItemAtPath:path getValueForKey:key] != nil);
}

+ (BOOL)xattrOfItemAtPath:(NSString *)path removeValueForKey:(NSString *)key
{
    int result = removexattr([path UTF8String], [key UTF8String], 0);
    return (result == 0);
}

+ (BOOL)xattrOfItemAtPath:(NSString *)path setValue:(NSString *)value forKey:(NSString *)key
{
    if (value == nil) {
        return NO;
    }
    
    int result = setxattr([path UTF8String], [key UTF8String], [value UTF8String], [value length], 0, 0);
    return (result == 0);
}

+ (id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error
{
    return [[self attributesOfItemAtPath:path error:error] objectForKey:key];
}

+ (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] attributesOfItemAtPath:path error:error];
}

+ (NSDate *)creationDateOfItemAtPath:(NSString *)path error:(NSError **)error
{
    return (NSDate *)[self attributeOfItemAtPath:path forKey:NSFileCreationDate error:error];
}

+ (NSDate *)modificationDateOfItemAtPath:(NSString *)path error:(NSError **)error
{
    return (NSDate *)[self attributeOfItemAtPath:path forKey:NSFileModificationDate error:error];
}

+ (NSURL *)urlForItemAtPath:(NSString *)path
{
    return [NSURL fileURLWithPath:path];
}

+ (NSString *)pathForPlistNamed:(NSString *)name
{
    NSString *nameExtension = [name pathExtension];
    NSString *plistExtension = @"plist";
    
    if ([nameExtension isEqualToString:@""]) {
        
        name = [name stringByAppendingPathExtension:plistExtension];
    }
    return [self filePathInResource:name];
}

+ (BOOL)isExecutableItemAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] isExecutableFileAtPath:path];
}

+ (BOOL)isReadableItemAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] isReadableFileAtPath:path];
}

+ (BOOL)isWritableItemAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] isWritableFileAtPath:path];
}

+ (BOOL)emptyCachesPath
{
    return [self removeFilesInDirAtPath:[self cachePath] error:nil];
}

+ (BOOL)emptyTemporaryPath
{
    return [self removeFilesInDirAtPath:[self temporaryPath] error:nil];
}

+ (BOOL)isFileExists:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)isDirExists:(NSString *)path
{
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    
    return isDir;
}

+ (BOOL)isDirItemAtPath:(NSString *)path error:(NSError **)error
{
    return ([self attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeDirectory);
}

+ (BOOL)isEmptyItemAtPath:(NSString *)path error:(NSError **)error
{
    return ([self isFileItemAtPath:path error:error] && ([[self sizeOfItemAtPath:path error:error] intValue] == 0)) || ([self isDirItemAtPath:path error:error] && ([[self listItemsInDirAtPath:path deep:NO] count] == 0));
}

+ (BOOL)isFileItemAtPath:(NSString *)path error:(NSError **)error
{
    return ([self attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeRegular);
}

+ (BOOL)isNotError:(NSError **)error
{
    return ((error == nil) || ((*error) == nil));
}


@end
