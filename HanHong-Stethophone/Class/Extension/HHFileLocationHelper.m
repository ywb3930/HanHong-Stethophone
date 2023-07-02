//
//  HHFileLocationHelper.m
//  NIM
//
//  Created by chris on 15/4/12.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "HHFileLocationHelper.h"
#import <sys/stat.h>

#define RDVideo    (@"video")
#define RDImage    (@"image")

@interface HHFileLocationHelper ()
+ (NSString *)filepathForDir: (NSString *)dirname filename: (NSString *)filename;
@end


@implementation HHFileLocationHelper
+ (BOOL)addSkipBackupAHMributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:&error];
    if(!success)
    {
        DDLogError(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}
+ (NSString *)getAppDocumentPath:(NSString *)path
{
    static NSString *appDocumentPath = nil;
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *pPath = [NSString stringWithFormat:@"Preferences/%@", path];
    NSString *preferPath = [libPath stringByAppendingPathComponent:pPath];
    
    DDLogInfo(@"preferPath:%@",preferPath);

    appDocumentPath= [[NSString alloc] initWithFormat:@"%@/",preferPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:appDocumentPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:appDocumentPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    [HHFileLocationHelper addSkipBackupAHMributeToItemAtURL:[NSURL fileURLWithPath:appDocumentPath]];
    return appDocumentPath;
    
}

+ (Boolean)deleteFilePath:(NSString *)path{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    return NO;
}

+ (NSString *)getAppDocumentPath
{
    static NSString *appDocumentPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        NSString *preferPath = [libPath stringByAppendingPathComponent:@"Preferences/"];
        
        DDLogInfo(@"preferPath:%@",preferPath);
        

        appDocumentPath= [[NSString alloc] initWithFormat:@"%@/",preferPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:appDocumentPath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:appDocumentPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        [HHFileLocationHelper addSkipBackupAHMributeToItemAtURL:[NSURL fileURLWithPath:appDocumentPath]];
    });
    return appDocumentPath;
    
}

+ (NSString *)getAppTempPath
{
    return NSTemporaryDirectory();
}

+ (NSString *)userDirectory
{
    NSString *documentPath = [HHFileLocationHelper getAppDocumentPath];
    NSString *userID = @"userId";
    if ([userID length] == 0)
    {
        DDLogError(@"Error: Get User Directory While UserID Is Empty");
    }
    NSString* userDirectory= [NSString stringWithFormat:@"%@%@/",documentPath,userID];
    if (![[NSFileManager defaultManager] fileExistsAtPath:userDirectory])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:userDirectory withIntermediateDirectories:NO attributes:nil error:nil];

    }
    return userDirectory;
}

+ (NSString *)resourceDir: (NSString *)resouceName
{
    NSString *dir = [[HHFileLocationHelper userDirectory] stringByAppendingPathComponent:resouceName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return dir;
}




+ (NSString *)filepathForVideo:(NSString *)filename
{
    return [HHFileLocationHelper filepathForDir:RDVideo filename:filename];
}

+ (NSString *)filepathForImage:(NSString *)filename
{
    return [HHFileLocationHelper filepathForDir:RDImage filename:filename];
}

+ (NSString *)genFilenameWithExt:(NSString *)ext
{
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    NSString *uuidStr = [[uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    NSString *name = [NSString stringWithFormat:@"%@",uuidStr];
    return [ext length] ? [NSString stringWithFormat:@"%@.%@",name,ext]:name;
}


#pragma mark - 辅助方法
+ (NSString *)filepathForDir:(NSString *)dirname filename:(NSString *)filename
{
    return [[HHFileLocationHelper resourceDir:dirname] stringByAppendingPathComponent:filename];
}

@end
