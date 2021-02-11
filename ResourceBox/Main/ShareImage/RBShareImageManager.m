//
//  RBShareImageManager.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/06.
//

#import "RBShareImageManager.h"

#import "RBShareImageFetchResultViewController.h"
#import "RBShareImageFetchResultManager.h"
#import "RBShareTextModel.h"

@implementation RBShareImageManager

+ (void)cellDidPressAtIndex:(NSInteger)index {
    switch (index) {
        case 0: {
            RBShareImageFetchResultViewController *vc = [[RBShareImageFetchResultViewController alloc] initWithNibName:@"RBShareImageFetchResultViewController" bundle:nil];
            vc.behavior = RBShareImageFetchResultBehaviorSourceWeibo | RBShareImageFetchResultBehaviorContainerGroup;
            [[RBSettingManager defaultManager].navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1: {
            RBShareImageFetchResultViewController *vc = [[RBShareImageFetchResultViewController alloc] initWithNibName:@"RBShareImageFetchResultViewController" bundle:nil];
            vc.behavior = RBShareImageFetchResultBehaviorSourceWeibo | RBShareImageFetchResultBehaviorContainerApp;
            [[RBSettingManager defaultManager].navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2: {
            [RBShareImageFetchResultManager moveImageFilesToAppContainer];
        }
            break;
        case 3: {
            [RBShareImageFetchResultManager cleanImageFolder];
        }
            break;
        default:
            break;
    }
}

@end
