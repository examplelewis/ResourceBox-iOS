//
//  RBWeiboShareFetchResultViewController.h
//  ResourceBox
//
//  Created by 龚宇 on 21/02/06.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, RBWeiboShareFetchResultBehavior) {
    RBWeiboShareFetchResultBehaviorNone                 = 0,
    RBWeiboShareFetchResultBehaviorContainerApp         = 1 << 0,
    RBWeiboShareFetchResultBehaviorContainerGroup       = 1 << 1,
    RBWeiboShareFetchResultBehaviorSourceWeibo          = 1 << 2,
};

@interface RBWeiboShareFetchResultViewController : UIViewController

@property (nonatomic, assign) RBWeiboShareFetchResultBehavior behavior;

@end

NS_ASSUME_NONNULL_END
