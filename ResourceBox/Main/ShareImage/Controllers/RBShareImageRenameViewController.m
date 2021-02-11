//
//  RBShareImageRenameViewController.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/10.
//

#import "RBShareImageRenameViewController.h"

#import "RBShareImageManager.h"
#import "RBShareTextModel.h"

static NSString * const RBDefaultFolderName = @"---没有输入内容---";

@interface RBShareImageRenameViewController () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *label;

@property (nonatomic, copy) NSString *input;
@property (nonatomic, copy) NSString *output;

@end

@implementation RBShareImageRenameViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUIAndData];
    
    [self generate];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // Data
    self.input = [UIPasteboard generalPasteboard].string;
    
    // UI
    self.textView.text = self.input;
}

#pragma mark - Generate
- (void)generate {
    self.output = [RBShareTextModel folderNameWithText:self.input];
    self.label.text = self.output;
}

#pragma mark - Action
- (IBAction)actionButtonDidPress:(UIButton *)sender {
    [self generate];
}
- (IBAction)confirmButtonDidPress:(UIButton *)sender {
    if ([self.output isEqualToString:RBDefaultFolderName]) {
        [self.view makeToast:@"输入内容有误" duration:1.5f position:CSToastPositionCenter];
        return;
    }
}

@end
