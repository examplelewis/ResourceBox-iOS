//
//  NSArray+RBAdd.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (RBAdd)

- (BOOL)isNotEmpty;

- (NSString *)stringValue;

#pragma mark - Export
- (void)exportToPath:(NSString *)path;
- (void)exportToPath:(NSString *)path behavior:(RBFileOpertaionBehavior)behavior;

- (void)exportToPlistPath:(NSString *)plistPath;
- (void)exportToPlistPath:(NSString *)plistPath behavior:(RBFileOpertaionBehavior)behavior;

@end

NS_ASSUME_NONNULL_END
