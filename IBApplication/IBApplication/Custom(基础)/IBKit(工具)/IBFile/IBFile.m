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

+ (NSMutableArray *)absoluteDirectories
{
    NSMutableArray *directories = [NSMutableArray arrayWithObjects:
                                   [self pathForApplicationSupportDir],
                                   [self pathForCachesDir],
                                   [self pathForDocumentsDir],
                                   [self pathForLibraryDir],
                                   [self pathForMainBundleDir],
                                   [self pathForTemporaryDir],
                                   nil];
    return directories;
}

+ (NSString *)absoluteDirForPath:(NSString *)path
{
    [self assertPath:path];
    
    if ([path isEqualToString:@"/"]) {
        return nil;
    }
    
    NSMutableArray *directories = [self absoluteDirectories];
    
    for (NSString *directory in directories) {
        NSRange indexOfDirectoryInPath = [path rangeOfString:directory];
        if (indexOfDirectoryInPath.location == 0) {
            return directory;
        }
    }
    
    return nil;
}

+ (NSString *)absolutePath:(NSString *)path
{
    [self assertPath:path];
    
    NSString *defaultDirectory = [self absoluteDirForPath:path];
    
    if (defaultDirectory != nil) {
        return path;
    } else {
        return [self pathForDocumentsDirWithPath:path];
    }
}

+ (void)assertPath:(NSString *)path
{
    NSAssert(path != nil, @"Invalid path. Path cannot be nil.");
    NSAssert(![path isEqualToString:@""], @"Invalid path. Path cannot be empty string.");
}

+ (id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error
{
    return [[self attributesOfItemAtPath:path error:error] objectForKey:key];
}

+ (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] attributesOfItemAtPath:[self absolutePath:path] error:error];
}

+ (BOOL)createDirForFileAtPath:(NSString *)path error:(NSError **)error
{
    NSString *pathLastChar = [path substringFromIndex:(path.length - 1)];
    
    if ([pathLastChar isEqualToString:@"/"]) {
        [NSException raise:@"Invalid path" format:@"file path can't have a trailing '/'."];
        return NO;
    }
    
    return [self createDirForPath:[[self absolutePath:path] stringByDeletingLastPathComponent] error:error];
}

+ (BOOL)createDirForPath:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] createDirectoryAtPath:[self absolutePath:path] withIntermediateDirectories:YES attributes:nil error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path error:(NSError **)error
{
    return [self createFileAtPath:path withContent:nil overwrite:NO error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite error:(NSError **)error
{
    return [self createFileAtPath:path withContent:nil overwrite:overwrite error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path withContent:(NSObject *)content error:(NSError **)error
{
    return [self createFileAtPath:path withContent:content overwrite:NO error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path withContent:(NSObject *)content overwrite:(BOOL)overwrite error:(NSError **)error
{
    if(![self existsItemAtPath:path] ||
       (overwrite && [self removeItemAtPath:path error:error] && [self isNotError:error])) {
        
        if ([self createDirForFileAtPath:path error:error]) {
            BOOL created = [[NSFileManager defaultManager] createFileAtPath:[self absolutePath:path] contents:nil attributes:nil];
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
    if (![self existsItemAtPath:toPath] ||
        (overwrite && [self removeItemAtPath:toPath error:error] && [self isNotError:error])) {
        if ([self createDirForFileAtPath:toPath error:error]) {
            BOOL copied = [[NSFileManager defaultManager] copyItemAtPath:[self absolutePath:path] toPath:[self absolutePath:toPath] error:error];
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
    if(![self existsItemAtPath:toPath] ||
       (overwrite && [self removeItemAtPath:toPath error:error] && [self isNotError:error])) {
        
        return ([self createDirForFileAtPath:toPath error:error] && [[NSFileManager defaultManager] moveItemAtPath:[self absolutePath:path] toPath:[self absolutePath:toPath] error:error]);
    } else {
        return NO;
    }
}

+ (BOOL)removeFilesInDirAtPath:(NSString *)path error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDirAtPath:path] error:error];
}

+ (BOOL)removeFilesInDirAtPath:(NSString *)path withExtension:(NSString *)extension error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDirAtPath:path withExtension:extension] error:error];
}

+ (BOOL)removeFilesInDirAtPath:(NSString *)path withPrefix:(NSString *)prefix error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDirAtPath:path withPrefix:prefix] error:error];
}

+ (BOOL)removeFilesInDirAtPath:(NSString *)path withSuffix:(NSString *)suffix error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listFilesInDirAtPath:path withSuffix:suffix] error:error];
}

+ (BOOL)removeItemsInDirAtPath:(NSString *)path error:(NSError **)error
{
    return [self removeItemsAtPaths:[self listItemsInDirAtPath:path deep:NO] error:error];
}

+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] removeItemAtPath:[self absolutePath:path] error:error];
}

+ (BOOL)removeItemsAtPaths:(NSArray *)paths error:(NSError **)error
{
    BOOL success = YES;
    
    for(NSString *path in paths) {
        success &= [self removeItemAtPath:[self absolutePath:path] error:error];
    }
    return success;
}

+ (BOOL)renameItemAtPath:(NSString *)path withName:(NSString *)name error:(NSError **)error
{
    NSRange indexOfSlash = [name rangeOfString:@"/"];
    
    if(indexOfSlash.location < name.length) {
        
        [NSException raise:@"Invalid name" format:@"file name can't contain a '/'."];
        return NO;
    }
    
    return [self moveItemAtPath:path toPath:[[[self absolutePath:path] stringByDeletingLastPathComponent] stringByAppendingPathComponent:name] error:error];
}

+ (NSDate *)creationDateOfItemAtPath:(NSString *)path error:(NSError **)error
{
    return (NSDate *)[self attributeOfItemAtPath:path forKey:NSFileCreationDate error:error];
}

+ (NSDate *)modificationDateOfItemAtPath:(NSString *)path error:(NSError **)error
{
    return (NSDate *)[self attributeOfItemAtPath:path forKey:NSFileModificationDate error:error];
}

+ (BOOL)emptyCachesDir
{
    return [self removeFilesInDirAtPath:[self pathForCachesDir] error:nil];
}

+ (BOOL)emptyTemporaryDir
{
    return [self removeFilesInDirAtPath:[self pathForTemporaryDir] error:nil];
}

+ (BOOL)existsItemAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self absolutePath:path]];
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

+ (BOOL)isExecutableItemAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] isExecutableFileAtPath:[self absolutePath:path]];
}

+ (BOOL)isNotError:(NSError **)error
{
    //the first check prevents EXC_BAD_ACCESS error in case methods are called passing nil to error argument
    //the second check prevents that the methods returns always NO just because the error pointer exists (so the first condition returns YES)
    return ((error == nil) || ((*error) == nil));
}

+ (BOOL)isReadableItemAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] isReadableFileAtPath:[self absolutePath:path]];
}

+ (BOOL)isWritableItemAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] isWritableFileAtPath:[self absolutePath:path]];
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

+ (NSArray *)listFilesInDirAtPath:(NSString *)path withExtension:(NSString *)extension
{
    return [self listFilesInDirAtPath:path withExtension:extension deep:NO];
}

+ (NSArray *)listFilesInDirAtPath:(NSString *)path withExtension:(NSString *)extension deep:(BOOL)deep
{
    NSArray *subpaths = [self listFilesInDirAtPath:path deep:deep];
    
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        NSString *subpathExtension = [[subpath pathExtension] lowercaseString];
        NSString *filterExtension = [[extension lowercaseString] stringByReplacingOccurrencesOfString:@"." withString:@""];
        
        return [subpathExtension isEqualToString:filterExtension];
    }]];
}

+ (NSArray *)listFilesInDirAtPath:(NSString *)path withPrefix:(NSString *)prefix
{
    return [self listFilesInDirAtPath:path withPrefix:prefix deep:NO];
}

+ (NSArray *)listFilesInDirAtPath:(NSString *)path withPrefix:(NSString *)prefix deep:(BOOL)deep
{
    NSArray *subpaths = [self listFilesInDirAtPath:path deep:deep];
    
    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *subpath = (NSString *)evaluatedObject;
        NSString *fileName = [subpath lastPathComponent];
        
        return ([fileName hasPrefix:prefix] || [fileName isEqualToString:prefix]);
    }]];
}

+ (NSArray *)listFilesInDirAtPath:(NSString *)path withSuffix:(NSString *)suffix
{
    return [self listFilesInDirAtPath:path withSuffix:suffix deep:NO];
}

+ (NSArray *)listFilesInDirAtPath:(NSString *)path withSuffix:(NSString *)suffix deep:(BOOL)deep
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
    NSString *absolutePath = [self absolutePath:path];
    NSArray *relativeSubpaths = (deep ? [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:absolutePath error:nil] : [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absolutePath error:nil]);
    
    NSMutableArray *absoluteSubpaths = [[NSMutableArray alloc] init];
    
    for(NSString *relativeSubpath in relativeSubpaths) {
        
        NSString *absoluteSubpath = [absolutePath stringByAppendingPathComponent:relativeSubpath];
        [absoluteSubpaths addObject:absoluteSubpath];
    }
    
    return [NSArray arrayWithArray:absoluteSubpaths];
}

+ (NSString *)pathForApplicationSupportDir
{
    return [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)pathForApplicationSupportDirWithPath:(NSString *)path
{
    return [[self pathForApplicationSupportDir] stringByAppendingPathComponent:path];
}

+ (NSString *)pathForCachesDir
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];;
}

+ (NSString *)pathForCachesDirWithPath:(NSString *)path
{
    return [[self pathForCachesDir] stringByAppendingPathComponent:path];
}

+ (NSString *)pathForDocumentsDir
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
}

+ (NSString *)pathForDocumentsDirWithPath:(NSString *)path
{
    return [[self pathForDocumentsDir] stringByAppendingPathComponent:path];
}

+ (NSString *)pathForLibraryDir
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)pathForLibraryDirWithPath:(NSString *)path
{
    return [[self pathForLibraryDir] stringByAppendingPathComponent:path];
}

+ (NSString *)pathForMainBundleDir
{
    return [NSBundle mainBundle].resourcePath;
}

+ (NSString *)pathForMainBundleDirWithPath:(NSString *)path
{
    return [[self pathForMainBundleDir] stringByAppendingPathComponent:path];
}

+ (NSString *)pathForPlistNamed:(NSString *)name
{
    NSString *nameExtension = [name pathExtension];
    NSString *plistExtension = @"plist";
    
    if([nameExtension isEqualToString:@""]) {
        
        name = [name stringByAppendingPathExtension:plistExtension];
    }
    return [self pathForMainBundleDirWithPath:name];
}

+ (NSString *)pathForTemporaryDir
{
    return NSTemporaryDirectory();
}

+ (NSString *)pathForTemporaryDirWithPath:(NSString *)path
{
    return [[self pathForTemporaryDir] stringByAppendingPathComponent:path];
}

+ (NSString *)readFileAtPath:(NSString *)path error:(NSError **)error
{
    return [self readFileAtPathAsString:path error:error];
}

+ (NSArray *)readFileAtPathAsArray:(NSString *)path
{
    return [NSArray arrayWithContentsOfFile:[self absolutePath:path]];
}

+ (NSObject *)readFileAtPathAsCustomModel:(NSString *)path
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self absolutePath:path]];
}

+ (NSData *)readFileAtPathAsData:(NSString *)path error:(NSError **)error
{
    return [NSData dataWithContentsOfFile:[self absolutePath:path] options:NSDataReadingMapped error:error];
}

+ (NSDictionary *)readFileAtPathAsDictionary:(NSString *)path
{
    return [NSDictionary dictionaryWithContentsOfFile:[self absolutePath:path]];
}

+ (UIImage *)readFileAtPathAsImage:(NSString *)path error:(NSError **)error
{
    NSData *data = [self readFileAtPathAsData:path error:error];
    
    if([self isNotError:error]) {
        return [UIImage imageWithData:data];
    }
    
    return nil;
}

+ (UIImageView *)readFileAtPathAsImageView:(NSString *)path error:(NSError **)error
{
    UIImage *image = [self readFileAtPathAsImage:path error:error];
    
    if([self isNotError:error]) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView sizeToFit];
        return imageView;
    }
    return nil;
}

+ (NSJSONSerialization *)readFileAtPathAsJSON:(NSString *)path error:(NSError **)error
{
    NSData *data = [self readFileAtPathAsData:path error:error];
    
    if([self isNotError:error]) {
        
        NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
        if([NSJSONSerialization isValidJSONObject:json]) {
            return json;
        }
    }
    return nil;
}

+ (NSMutableArray *)readFileAtPathAsMutableArray:(NSString *)path
{
    return [NSMutableArray arrayWithContentsOfFile:[self absolutePath:path]];
}

+ (NSMutableData *)readFileAtPathAsMutableData:(NSString *)path error:(NSError **)error
{
    return [NSMutableData dataWithContentsOfFile:[self absolutePath:path] options:NSDataReadingMapped error:error];
}

+ (NSMutableDictionary *)readFileAtPathAsMutableDictionary:(NSString *)path
{
    return [NSMutableDictionary dictionaryWithContentsOfFile:[self absolutePath:path]];
}

+ (NSString *)readFileAtPathAsString:(NSString *)path error:(NSError **)error
{
    return [NSString stringWithContentsOfFile:[self absolutePath:path] encoding:NSUTF8StringEncoding error:error];
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
    
    if(size != nil && [self isNotError:error]) {
        
        return [self sizeFormatted:size];
    }
    return nil;
}

+ (NSString *)sizeFormattedOfFileAtPath:(NSString *)path error:(NSError **)error
{
    NSNumber *size = [self sizeOfFileAtPath:path error:error];
    
    if(size != nil && [self isNotError:error]) {
        
        return [self sizeFormatted:size];
    }
    
    return nil;
}

+ (NSString *)sizeFormattedOfItemAtPath:(NSString *)path error:(NSError **)error
{
    NSNumber *size = [self sizeOfItemAtPath:path error:error];
    
    if(size != nil && [self isNotError:error]) {
        
        return [self sizeFormatted:size];
    }
    return nil;
}

+ (NSNumber *)sizeOfDirAtPath:(NSString *)path error:(NSError **)error
{
    if([self isDirItemAtPath:path error:error])
    {
        if([self isNotError:error]) {
            
            NSNumber *size = [self sizeOfItemAtPath:path error:error];
            double sizeValue = [size doubleValue];
            
            if([self isNotError:error]) {
                
                NSArray *subpaths = [self listItemsInDirAtPath:path deep:YES];
                NSUInteger subpathsCount = [subpaths count];
                
                for(NSUInteger i = 0; i < subpathsCount; i++) {
                    
                    NSString *subpath = [subpaths objectAtIndex:i];
                    NSNumber *subpathSize = [self sizeOfItemAtPath:subpath error:error];
                    
                    if([self isNotError:error]) {
                        
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
    if([self isFileItemAtPath:path error:error]) {
        
        if([self isNotError:error]) {
            
            return [self sizeOfItemAtPath:path error:error];
        }
    }
    return nil;
}

+ (NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError **)error
{
    return (NSNumber *)[self attributeOfItemAtPath:path forKey:NSFileSize error:error];
}

+ (NSURL *)urlForItemAtPath:(NSString *)path
{
    return [NSURL fileURLWithPath:[self absolutePath:path]];
}

+ (BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError **)error
{
    if(content == nil) {
        
        [NSException raise:@"Invalid content" format:@"content can't be nil."];
    }
    
    [self createFileAtPath:path withContent:nil overwrite:YES error:error];
    
    NSString *absolutePath = [self absolutePath:path];
    
    if([content isKindOfClass:[NSMutableArray class]]) {
        
        [((NSMutableArray *)content) writeToFile:absolutePath atomically:YES];
        
    } else if([content isKindOfClass:[NSArray class]]) {
        
        [((NSArray *)content) writeToFile:absolutePath atomically:YES];
        
    } else if([content isKindOfClass:[NSMutableData class]]) {
        
        [((NSMutableData *)content) writeToFile:absolutePath atomically:YES];
        
    } else if([content isKindOfClass:[NSData class]]) {
        
        [((NSData *)content) writeToFile:absolutePath atomically:YES];
        
    } else if([content isKindOfClass:[NSMutableDictionary class]]) {
        
        [((NSMutableDictionary *)content) writeToFile:absolutePath atomically:YES];
        
    } else if([content isKindOfClass:[NSDictionary class]]) {
        
        [((NSDictionary *)content) writeToFile:absolutePath atomically:YES];
        
    } else if([content isKindOfClass:[NSJSONSerialization class]]) {
        
        [((NSDictionary *)content) writeToFile:absolutePath atomically:YES];
        
    } else if([content isKindOfClass:[NSMutableString class]]) {
        
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:absolutePath atomically:YES];
        
    } else if([content isKindOfClass:[NSString class]]) {
        
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:absolutePath atomically:YES];
        
    } else if([content isKindOfClass:[UIImage class]]) {
        
        [UIImagePNGRepresentation((UIImage *)content) writeToFile:absolutePath atomically:YES];
        
    } else if([content isKindOfClass:[UIImageView class]]) {
        
        return [self writeFileAtPath:absolutePath content:((UIImageView *)content).image error:error];
        
    } else if([content conformsToProtocol:@protocol(NSCoding)]) {
        
        [NSKeyedArchiver archiveRootObject:content toFile:absolutePath];
        
    } else {
        [NSException raise:@"Invalid content type" format:@"content of type %@ is not handled.", NSStringFromClass([content class])];
        
        return NO;
    }
    
    return YES;
}

+ (NSDictionary *)metadataOfImageAtPath:(NSString *)path
{
    if([self isFileItemAtPath:path error:nil]) {
        
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
    
    if(metadata) {
        
        return [metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    }
    return nil;
}

+ (NSDictionary *)tiffDataOfImageAtPath:(NSString *)path
{
    NSDictionary *metadata = [self metadataOfImageAtPath:path];
    
    if(metadata) {
        return [metadata objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
    }
    return nil;
}

+ (NSDictionary *)xattrOfItemAtPath:(NSString *)path
{
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    
    const char *upath = [path UTF8String];
    
    ssize_t ukeysSize = listxattr(upath, NULL, 0, 0);
    
    if( ukeysSize > 0 ) {
        
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
    
    if( uvalueSize > -1 ) {
        
        if( uvalueSize == 0 ) {
            
            value = @"";
        } else {
            
            char *uvalue = malloc(uvalueSize);
            if( uvalue ) {
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
    if(value == nil) {
        return NO;
    }
    
    int result = setxattr([path UTF8String], [key UTF8String], [value UTF8String], [value length], 0, 0);
    return (result == 0);
}

@end
