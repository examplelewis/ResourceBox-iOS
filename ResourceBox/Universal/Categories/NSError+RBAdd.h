//
//  NSError+RBAdd.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/26.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RBErrorType) {
    RBErrorTypeDownloadOther,
    RBErrorTypeDownloadConnectionLost,
};

@interface NSError (RBAdd)

- (NSString *)downloadUrl;
- (RBErrorType)downloadErrorType;

@end

NS_ASSUME_NONNULL_END
