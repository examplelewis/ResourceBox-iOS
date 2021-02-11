//
//  RBShareImageRenameViewController.h
//  ResourceBox
//
//  Created by 龚宇 on 21/02/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RBShareImageRenameDelegate <NSObject>

- (void)didConfirmNewFolderName:(NSString *)newFolderName index:(NSInteger)index;

@end

@interface RBShareImageRenameViewController : UIViewController

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, weak) id<RBShareImageRenameDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
