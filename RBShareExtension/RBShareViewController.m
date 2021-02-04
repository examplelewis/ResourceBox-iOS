//
//  RBShareViewController.m
//  RBShareExtension
//
//  Created by 龚宇 on 21/02/04.
//

#import "RBShareViewController.h"

@interface RBShareViewController ()

@end

@implementation RBShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)postButtonDidPress:(UIButton *)sender {
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (void)cancelButtonDidPress:(UIButton *)sender {
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"CustomShareError" code:NSUserCancelledError userInfo:nil]];
}

@end
