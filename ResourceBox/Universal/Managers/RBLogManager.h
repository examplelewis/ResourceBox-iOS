//
//  RBLogManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, RBLogBehavior) {
    RBLogBehaviorNone              = 0,
    RBLogBehaviorLevelDefault      = 1 << 0,
    RBLogBehaviorLevelWarning      = 1 << 1,
    RBLogBehaviorLevelError        = 1 << 2,
    RBLogBehaviorOnView            = 1 << 5,   // 在页面上显示Log
    RBLogBehaviorOnDDLog           = 1 << 6,   // 使用CocoaLumberJack处理Log
    RBLogBehaviorOnBoth            = RBLogBehaviorOnView | RBLogBehaviorOnDDLog, // 在页面上显示Log, 使用CocoaLumberJack处理Log
    RBLogBehaviorTime              = 1 << 9,   // 显示时间
    RBLogBehaviorAppend            = 1 << 10,  // 新日志以添加的形式
    
    RBLogBehaviorOnBothTimeAppend    = RBLogBehaviorOnBoth | RBLogBehaviorTime | RBLogBehaviorAppend,
    RBLogBehaviorOnViewTimeAppend    = RBLogBehaviorOnView | RBLogBehaviorTime | RBLogBehaviorAppend,
    RBLogBehaviorOnDDLogTimeAppend   = RBLogBehaviorOnDDLog | RBLogBehaviorTime | RBLogBehaviorAppend,
    
    RBLogBehaviorOnBothAppend        = RBLogBehaviorOnBoth | RBLogBehaviorAppend,
    RBLogBehaviorOnViewAppend        = RBLogBehaviorOnView | RBLogBehaviorAppend,
    RBLogBehaviorOnDDLogAppend       = RBLogBehaviorOnDDLog | RBLogBehaviorAppend,
    
    RBLogBehaviorOnBothTime          = RBLogBehaviorOnBoth | RBLogBehaviorTime,
    RBLogBehaviorOnViewTime          = RBLogBehaviorOnView | RBLogBehaviorTime,
    RBLogBehaviorOnDDLogTime         = RBLogBehaviorOnDDLog | RBLogBehaviorTime,
};

@interface RBLogManager : NSObject

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - Log Clean / Reset
- (void)clean;
- (void)reset;

#pragma mark - Log 换行
- (void)addNewlineLog;

#pragma mark - Log 页面和文件，显示时间，添加新的日志
- (void)addDefaultLogWithFormat:(NSString *)format, ...;
- (void)addWarningLogWithFormat:(NSString *)format, ...;
- (void)addErrorLogWithFormat:(NSString *)format, ...;

#pragma mark - Log 页面和文件，显示时间，新的日志覆盖之前的日志
- (void)addReplaceDefaultLogWithFormat:(NSString *)format, ...;
- (void)addReplaceWarningLogWithFormat:(NSString *)format, ...;
- (void)addReplaceErrorLogWithFormat:(NSString *)format, ...;

#pragma mark - Log 自定义
- (void)addDefaultLogWithBehavior:(RBLogBehavior)behavior format:(NSString *)format, ...;
- (void)addWarningLogWithBehavior:(RBLogBehavior)behavior format:(NSString *)format, ...;
- (void)addErrorLogWithBehavior:(RBLogBehavior)behavior format:(NSString *)format, ...;

#pragma mark - Local Log
- (void)saveDefaultLocalLog:(NSString *)log;
- (void)saveWarningLocalLog:(NSString *)log;
- (void)saveErrorLocalLog:(NSString *)log;

@end

NS_ASSUME_NONNULL_END
