//
//  TTFileLocationHelper.h
//  NIM
//
//  Created by chris on 15/4/12.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ImageExt   (@"jpg")


@interface HHFileLocationHelper : NSObject

+ (NSString *)getAppDocumentPath;

+ (NSString *)getAppTempPath;

+ (NSString *)userDirectory;

+ (NSString *)genFilenameWithExt:(NSString *)ext;

+ (NSString *)filepathForVideo:(NSString *)filename;

+ (NSString *)filepathForImage:(NSString *)filename;

+ (NSString *)getAppDocumentPath:(NSString *)path;

+ (Boolean)deleteFilePath:(NSString *)path;
+ (Boolean)fileExistsAtPath:(NSString *)path;

@end
