//
//  RBLogManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "RBLogManager.h"

@interface RBLogManager ()

//@property (strong) NSMutableArray *logs; // 日志
@property (strong) NSAttributedString *newestLog;
@property (strong) NSDate *current;
@property (strong) NSLock *lock;

@end

@implementation RBLogManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static RBLogManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.lock = [NSLock new];
//        self.logs = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Log Clean / Reset
- (void)clean {
    [self.lock lock];
    self.newestLog = nil;
//    [self.logs removeAllObjects];
    [self.lock unlock];
}
- (void)reset {
    [self.lock lock];
    self.current = [NSDate date];
    self.newestLog = nil;
//    [self.logs removeAllObjects];
    [self.lock unlock];
}

#pragma mark - Log 换行
- (void)addNewlineLog {
    [self _addLogWithBehavior:RBLogBehaviorLevelDefault | RBLogBehaviorOnBothTimeAppend log:@""];
}

#pragma mark - Log 页面和文件，显示时间，添加新的日志
- (void)addDefaultLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:RBLogBehaviorLevelDefault | RBLogBehaviorOnBothTimeAppend log:log];
}
- (void)addWarningLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:RBLogBehaviorLevelWarning | RBLogBehaviorOnBothTimeAppend log:log];
}
- (void)addErrorLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:RBLogBehaviorLevelError | RBLogBehaviorOnBothTimeAppend log:log];
}

#pragma mark - Log 页面和文件，显示时间，新的日志覆盖之前的日志
- (void)addReplaceDefaultLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:RBLogBehaviorLevelDefault | RBLogBehaviorOnBothTime log:log];
}
- (void)addReplaceWarningLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:RBLogBehaviorLevelWarning | RBLogBehaviorOnBothTime log:log];
}
- (void)addReplaceErrorLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:RBLogBehaviorLevelError | RBLogBehaviorOnBothTime log:log];
}

#pragma mark - Log 自定义
- (void)addDefaultLogWithBehavior:(RBLogBehavior)behavior format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:RBLogBehaviorLevelDefault | behavior log:log];
}
- (void)addWarningLogWithBehavior:(RBLogBehavior)behavior format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:RBLogBehaviorLevelWarning | behavior log:log];
}
- (void)addErrorLogWithBehavior:(RBLogBehavior)behavior format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:RBLogBehaviorLevelError | behavior log:log];
}

#pragma mark - Log 内部实现
- (void)_addLogWithBehavior:(RBLogBehavior)behavior log:(NSString *)log {
    if (behavior & RBLogBehaviorNone) {
        return;
    }
    
    // 日志内容
    NSString *logs = @"";
    if (behavior & RBLogBehaviorTime) {
        if (self.current) {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.current];
            logs = [logs stringByAppendingFormat:@"%@ | %@\t\t", [[NSDate date] stringWithFormat:RBTimeFormatyMdHmsS], [RBUtilityManager humanReadableTimeFromInterval:interval]];
        } else {
            logs = [logs stringByAppendingFormat:@"%@\t\t", [[NSDate date] stringWithFormat:RBTimeFormatyMdHmsS]];
        }
    }
    logs = [logs stringByAppendingString:log];
    
    // 本地日志
    if (behavior & RBLogBehaviorOnDDLog) {
        // 本地文件不记录时间，因为CocoaLumberJack会自动添加时间
        if (behavior & RBLogBehaviorLevelDefault) {
            [self saveDefaultLocalLog:log];
        } else if (behavior & RBLogBehaviorLevelWarning) {
            [self saveWarningLocalLog:log];
        } else if (behavior & RBLogBehaviorLevelError) {
            [self saveErrorLocalLog:log];
        }
    }
}

#pragma mark - Local Log
- (void)saveDefaultLocalLog:(NSString *)log {
    DDLogInfo(@"%@", log);
}
- (void)saveWarningLocalLog:(NSString *)log {
    DDLogWarn(@"%@", log);
}
- (void)saveErrorLocalLog:(NSString *)log {
    DDLogError(@"%@", log);
}

@end
