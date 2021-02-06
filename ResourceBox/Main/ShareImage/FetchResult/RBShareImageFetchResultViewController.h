//
//  RBShareImageFetchResultViewController.h
//  ResourceBox
//
//  Created by 龚宇 on 21/02/06.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, RBShareImageFetchResultBehavior) {
    RBShareImageFetchResultBehaviorNone                 = 0,
    RBShareImageFetchResultBehaviorContainerApp         = 1 << 0,
    RBShareImageFetchResultBehaviorContainerGroup       = 1 << 1,
    RBShareImageFetchResultBehaviorSourceWeibo          = 1 << 2,
};

@interface RBShareImageFetchResultViewController : UIViewController

@property (nonatomic, assign) RBShareImageFetchResultBehavior behavior;

@end

NS_ASSUME_NONNULL_END
