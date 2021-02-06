//
//  RBFileManager.m
//  MyComicView
//
//  Created by 龚宇 on 16/08/03.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "RBFileManager.h"

@implementation RBFileManager

#pragma mark - Create
+ (BOOL)createFolderAtPath:(NSString *)folderPath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        return YES;
    } else {
        NSError *error;
        if ([[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            return YES;
        } else {
            [[RBLogManager defaultManager] addErrorLogWithFormat:@"创建文件夹 %@ 时发生错误: \n%@", folderPath, [error localizedDescription]];
            return NO;
        }
    }
}

#pragma mark - Move
+ (void)moveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    NSError *error;
    if (![[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:[RBFileManager removeSeparatorInPathComponentsAtContentPath:toPath] error:&error]) {
        [[RBLogManager defaultManager] addErrorLogWithFormat:@"移动文件 %@ 时发生错误: %@", fromPath, [error localizedDescription]];
    }
}
+ (void)moveItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL {
    [RBFileManager moveItemFromPath:[RBFileManager filePathFromFileURL:fromURL] toPath:[RBFileManager filePathFromFileURL:toURL]];
}
+ (void)moveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error {
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:[RBFileManager removeSeparatorInPathComponentsAtContentPath:toPath] error:error];
}
+ (void)moveItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL error:(NSError **)error {
    [RBFileManager moveItemFromPath:[RBFileManager filePathFromFileURL:fromURL] toPath:[RBFileManager filePathFromFileURL:toURL] error:error];
}

#pragma mark - Copy
+ (void)copyItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    NSError *error;
    if (![[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:[RBFileManager removeSeparatorInPathComponentsAtContentPath:toPath] error:&error]) {
        [[RBLogManager defaultManager] addErrorLogWithFormat:@"拷贝文件 %@ 时发生错误: %@", fromPath, [error localizedDescription]];
    }
}
+ (void)copyItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL {
    [RBFileManager copyItemFromPath:[RBFileManager filePathFromFileURL:fromURL] toPath:[RBFileManager filePathFromFileURL:toURL]];
}
+ (BOOL)copyItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError *__autoreleasing  _Nullable *)error {
    return [[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:[RBFileManager removeSeparatorInPathComponentsAtContentPath:toPath] error:error];
}
+ (BOOL)copyItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL error:(NSError *__autoreleasing  _Nullable *)error {
    return [RBFileManager copyItemFromPath:[RBFileManager filePathFromFileURL:fromURL] toPath:[RBFileManager filePathFromFileURL:toURL] error:error];
}

#pragma mark - RBShareExtension
+ (NSURL *)containerURL {
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.gongyuTest.ResourceBox"];
}
+ (NSString *)shareExtensionWeiboImagesFolderPath {
    return [[RBFileManager containerURL].path stringByAppendingPathComponent:@"WeiboImages"];
}
+ (NSString *)shareExtensionFilePathForShareImageWithName:(NSString *)fileName {
    return [[[RBFileManager containerURL].path stringByAppendingPathComponent:@"WeiboImages"] stringByAppendingPathComponent:fileName];
}

#pragma mark - File Path
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    contents = [RBFileManager filterReturnedContents:contents];
    
    for (NSString *content in contents) {
        NSString *filePath = [folderPath stringByAppendingPathComponent:content];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
        
        if (!folderFlag) {
            [results addObject:filePath];
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath extensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    contents = [RBFileManager filterReturnedContents:contents];
    
    for (NSString *extension in extensions) {
        NSArray *filteredContents = [contents filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nonnull content, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [content.pathExtension caseInsensitiveCompare:extension] == NSOrderedSame;
        }]];
        for (NSString *content in filteredContents) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:content];
            BOOL folderFlag = YES;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
            
            if (!folderFlag) {
                [results addObject:filePath];
            }
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath withoutExtensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *extensionsFiles = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    contents = [RBFileManager filterReturnedContents:contents];
    NSMutableArray<NSString *> *results = [NSMutableArray arrayWithArray:[contents bk_map:^id(NSString *obj) {
        return [folderPath stringByAppendingPathComponent:obj];
    }]];
    
    for (NSString *extension in extensions) {
        NSArray *filteredContents = [contents filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nonnull content, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [content.pathExtension caseInsensitiveCompare:extension] == NSOrderedSame;
        }]];
        for (NSString *content in filteredContents) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:content];
            BOOL folderFlag = YES;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
            
            if (!folderFlag) {
                [extensionsFiles addObject:filePath];
            }
        }
    }
    
    [results removeObjectsInArray:extensionsFiles];
    
    return [results copy];
}
+ (NSArray<NSString *> *)folderPathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    contents = [RBFileManager filterReturnedContents:contents];
    
    for (NSString *content in contents) {
        NSString *folder = [folderPath stringByAppendingPathComponent:content];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)contentPathsInFolder:(NSString *)folderPath {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    contents = [RBFileManager filterReturnedContents:contents];
    return [contents bk_map:^id(NSString *obj) {
        return [folderPath stringByAppendingPathComponent:obj];
    }];
}
+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    contents = [RBFileManager filterReturnedContents:contents];
    
    for (NSString *content in contents) {
        NSString *filePath = [folderPath stringByAppendingPathComponent:content];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
        
        if (!folderFlag) {
            [results addObject:filePath];
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath extensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    contents = [RBFileManager filterReturnedContents:contents];
    
    for (NSString *extension in extensions) {
        NSArray *filteredContents = [contents filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nonnull content, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [content.pathExtension caseInsensitiveCompare:extension] == NSOrderedSame;
        }]];
        for (NSString *content in filteredContents) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:content];
            BOOL folderFlag = YES;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
            
            if (!folderFlag) {
                [results addObject:filePath];
            }
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath withoutExtensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *extensionsFiles = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    contents = [RBFileManager filterReturnedContents:contents];
    NSMutableArray<NSString *> *results = [NSMutableArray arrayWithArray:[contents bk_map:^id(NSString *obj) {
        return [folderPath stringByAppendingPathComponent:obj];
    }]];
    
    for (NSString *extension in extensions) {
        NSArray *filteredContents = [contents filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nonnull content, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [content.pathExtension caseInsensitiveCompare:extension] == NSOrderedSame;
        }]];
        for (NSString *content in filteredContents) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:content];
            BOOL folderFlag = YES;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
            
            if (!folderFlag) {
                [extensionsFiles addObject:filePath];
            }
        }
    }
    
    [results removeObjectsInArray:extensionsFiles];
    
    return [results copy];
}
+ (NSArray<NSString *> *)allFolderPathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    contents = [RBFileManager filterReturnedContents:contents];
    
    for (NSString *content in contents) {
        NSString *folder = [folderPath stringByAppendingPathComponent:content];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)allContentPathsInFolder:(NSString *)folderPath {
    NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    contents = [RBFileManager filterReturnedContents:contents];
    return [contents bk_map:^id(NSString *obj) {
        return [folderPath stringByAppendingPathComponent:obj];
    }];
}

#pragma mark - Attributes
+ (NSDictionary *)allAttributesOfItemAtPath:(NSString *)path {
    NSError *error;
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    return [NSDictionary dictionaryWithDictionary:dict];
}
+ (id)attribute:(NSString *)attribute ofItemAtPath:(NSString *)path {
    return [self allAttributesOfItemAtPath:path][attribute];
}

#pragma mark - Check
+ (BOOL)fileExistsAtPath:(NSString *)contentPath {
    return [[NSFileManager defaultManager] fileExistsAtPath:contentPath];
}
+ (BOOL)contentIsFolderAtPath:(NSString *)contentPath {
    BOOL folderFlag = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:contentPath isDirectory:&folderFlag];
    return folderFlag;
}
+ (BOOL)isEmptyFolderAtPath:(NSString *)folderPath {
    return [self contentPathsInFolder:folderPath].count == 0;
}

#pragma mark - Tool
+ (NSURL *)fileURLFromFilePath:(NSString *)filePath {
    return [NSURL fileURLWithPath:filePath];
}
+ (NSString *)filePathFromFileURL:(NSURL *)fileURL {
    return fileURL.path;
}
+ (NSArray<NSURL *> *)fileURLsFromFilePaths:(NSArray<NSString *> *)filePaths {
    return [filePaths bk_map:^id(NSString *obj) {
        return [NSURL fileURLWithPath:obj];
    }];
}
+ (NSArray<NSString *> *)filePathsFromFileURLs:(NSArray<NSURL *> *)fileURLs {
    return [fileURLs bk_map:^id(NSURL *obj) {
        return obj.path;
    }];
}
+ (BOOL)fileShouldIgnore:(NSString *)fileName {
    if ([fileName.lastPathComponent hasPrefix:@"."]) {
        return YES;
    }
    if ([fileName hasSuffix:@"DS_Store"]) {
        return YES;
    }
    
    return NO;
}
+ (NSArray<NSString *> *)filterReturnedContents:(NSArray<NSString *> *)contents {
    return [contents bk_select:^BOOL(NSString *content) {
        return ![RBFileManager fileShouldIgnore:content];
    }];
}
+ (NSString *)removeSeparatorInPathComponentsAtContentPath:(NSString *)contentPath {
    NSString *contentPathCopy = [contentPath copy];
    NSMutableArray *contentPathCopyComponents = [NSMutableArray arrayWithArray:contentPathCopy.pathComponents];
    for (NSInteger i = 0; i < contentPathCopyComponents.count; i++) {
        if ([contentPathCopyComponents[i] containsString:@"/"] && i != 0) {
            contentPathCopyComponents[i] = [contentPathCopyComponents[i] stringByReplacingOccurrencesOfString:@"/" withString:@" "];
        }
    }
    contentPathCopy = [contentPathCopyComponents componentsJoinedByString:@"/"];
    contentPathCopy = [contentPathCopy substringFromIndex:1];
    
    return contentPathCopy;
}

@end
