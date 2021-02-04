//
//  RBSettingManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RBSettingManager : NSObject

@property (strong, readonly) NSArray *mimeImageTypes;
@property (strong, readonly) NSArray *mimeVideoTypes;
@property (strong, readonly) NSArray *mimeImageAndVideoTypes;


@property (strong, readonly) NSString *homePath;
@property (strong, readonly) NSString *documentPath;
@property (strong, readonly) NSString *libraryPath;
@property (strong, readonly) NSString *cachesPath;
@property (strong, readonly) NSString *applicationSupportPath;
@property (strong, readonly) NSString *preferencePath;
@property (strong, readonly) NSString *temPath;

@property (strong, readonly) NSString *mainDatabasesFolderPath;
@property (strong, readonly) NSString *preferenceFilePath;

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - Configure
- (void)updatePreferences;

#pragma mark - Types
- (BOOL)isImageAtFilePath:(NSString *)filePath;
- (BOOL)isVideoAtFilePath:(NSString *)filePath;

#pragma mark - Paths
- (NSString *)pathOfContentInDocumentFolder:(NSString *)component;
- (NSString *)pathOfContentInMainDatabasesFolder:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
