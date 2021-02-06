//
//  RBShareFileManager.m
//  RBShareExtension
//
//  Created by 龚宇 on 21/02/06.
//

#import "RBShareFileManager.h"

@implementation RBShareFileManager

+ (NSURL *)containerURL {
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.gongyuTest.ResourceBox"];
}

+ (NSString *)filePathForShareImageWithName:(NSString *)imageName {
    return [[[self containerURL].absoluteString stringByAppendingPathComponent:@"WeiboImages"] stringByAppendingPathComponent:imageName];
}

@end
