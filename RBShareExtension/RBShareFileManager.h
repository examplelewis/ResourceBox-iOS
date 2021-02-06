//
//  RBShareFileManager.h
//  RBShareExtension
//
//  Created by 龚宇 on 21/02/06.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RBShareFileManager : NSObject

+ (NSString *)filePathForShareImageWithName:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
