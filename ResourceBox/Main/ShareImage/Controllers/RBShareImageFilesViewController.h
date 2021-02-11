//
//  RBShareImageFilesViewController.h
//  ResourceBox
//
//  Created by 龚宇 on 21/02/09.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RBShareImageFilesViewController : UIViewController

- (instancetype)initWithFolderPath:(NSString *)folderPath andUsername:(NSString *)username;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
