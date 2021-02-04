//
//  NSString+RBAdd.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "NSString+RBAdd.h"

@implementation NSString (RBAdd)

- (BOOL)isNotEmpty {
    return [self isKindOfClass:[NSString class]] && self.length > 0;
}

- (NSString *)md5Middle {
    if (self.length != 32) { // MD5都是32位的
        return self;
    } else {
        return [self substringWithRange:NSMakeRange(self.length / 4, self.length / 2)];
    }
}
- (NSString *)md5Middle8 {
    if (self.length != 32) { // MD5都是32位的
        return self;
    } else {
        return [self substringWithRange:NSMakeRange(self.length * 3 / 8, self.length / 4)];
    }
}

#pragma mark - Export
- (void)exportToPath:(NSString *)path {
    [self exportToPath:path behavior:RBFileOpertaionBehaviorNone];
}
- (void)exportToPath:(NSString *)path behavior:(RBFileOpertaionBehavior)behavior {
    BOOL showNoneLog = behavior & RBFileOpertaionBehaviorShowNoneLog;
    BOOL showSuccessLog = behavior & RBFileOpertaionBehaviorShowSuccessLog;
    BOOL exportNoneLog = behavior & RBFileOpertaionBehaviorExportNoneLog;
    
    if (!self.isNotEmpty) {
        if (showNoneLog) {
            [[RBLogManager defaultManager] addWarningLogWithFormat:@"输出到: %@ 的内容为空%@，已忽略", path];
        }
        if (!exportNoneLog) {
            return;
        }
    }
    
    NSError *error;
    if ([self writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        if (showSuccessLog) {
            [[RBLogManager defaultManager] addDefaultLogWithFormat:@"结果文件导出成功，请查看：%@", path];
        }
    } else {
        [[RBLogManager defaultManager] addErrorLogWithFormat:@"导出结果文件出错：%@", error.localizedDescription];
    }
}

@end
