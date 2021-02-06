//
//  RBShareViewController.m
//  RBShareExtension
//
//  Created by 龚宇 on 21/02/04.
//

#import "RBShareViewController.h"

#import "RBShareFileManager.h"

@interface RBShareViewController ()

@property (nonatomic, copy) NSArray *imageFilePaths;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, assign) NSInteger loadCount;
@property (nonatomic, assign) BOOL loadSuccess;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger countDown;

@property (strong, nonatomic) IBOutlet UIButton *postButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UITextView *statusTextView;
@property (strong, nonatomic) IBOutlet UIButton *URLButton;
@property (strong, nonatomic) IBOutlet UILabel *imageNumsLabel;

@property (strong, nonatomic) IBOutlet UIView *waitingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UILabel *waitingLabel;

@property (nonatomic, strong) NSDate *startDate;

@end

@implementation RBShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUIAndData];
    
    [self.indicator startAnimating];
    
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf readItems];
        [strongSelf startTimer];
    });
}

- (void)setupUIAndData {
    // UI
    self.contentView.hidden = YES;
    self.waitingView.hidden = NO;
    
    // Data
    self.imageFilePaths = @[];
    self.loadCount = 0;
}

- (void)readItems {
    self.startDate = [NSDate date];
    
    NSExtensionItem *item = (NSExtensionItem *)self.extensionContext.inputItems.firstObject;
    for (NSInteger i = 0; i < item.attachments.count; i++) {
        NSItemProvider *provider = (NSItemProvider *)item.attachments[i];
//        NSLog(@"%@", provider.registeredTypeIdentifiers);
        
        if ([provider hasItemConformingToTypeIdentifier:@"public.plain-text"]) {
            [provider loadItemForTypeIdentifier:@"public.plain-text" options:nil completionHandler:^(NSString *text, NSError *error) {
                if (text) {
                    self.text = text;
                }
                
                [self finishLoadItems];
            }];
        }

        if ([provider hasItemConformingToTypeIdentifier:@"public.image"]) {
            [provider loadItemForTypeIdentifier:@"public.jpeg" options:nil completionHandler:^(UIImage *image, NSError *error) {
                if (image) {
                    NSString *fileNamePrefix = [NSString stringWithFormat:@"%@", self.startDate];
                    NSString *fileNameSuffix = [NSString stringWithFormat:@"%@", [self.startDate dateByAddingTimeInterval:i + 100]];
                    NSString *fileNameAndExt = [NSString stringWithFormat:@"%@%@.jpg", fileNamePrefix.md5String.md5Middle, fileNameSuffix.md5String.md5Middle];
//                    NSString *fileNameAndExt = [NSString stringWithFormat:@"%@%@.jpg", fileNamePrefix, fileNameSuffix];
                    
                    NSString *imageFilePath = [RBShareFileManager filePathForShareImageWithName:fileNameAndExt];
                    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
                    [imageData writeToFile:imageFilePath atomically:YES];
                    
                    self.imageFilePaths = [self.imageFilePaths arrayByAddingObject:imageFilePath];
                }
                
                [self finishLoadItems];
            }];
            
            [provider loadItemForTypeIdentifier:@"public.png" options:nil completionHandler:^(UIImage *image, NSError *error) {
                if (image) {
                    NSString *fileNamePrefix = [NSString stringWithFormat:@"%@", self.startDate];
                    NSString *fileNameSuffix = [NSString stringWithFormat:@"%@", [self.startDate dateByAddingTimeInterval:i + 100]];
//                    NSString *fileNameAndExt = [NSString stringWithFormat:@"%@%@.png", fileNamePrefix.md5String.md5Middle, fileNameSuffix.md5String.md5Middle];
                    NSString *fileNameAndExt = [NSString stringWithFormat:@"%@%@.jpg", fileNamePrefix, fileNameSuffix];
                    
                    NSString *imageFilePath = [RBShareFileManager filePathForShareImageWithName:fileNameAndExt];
                    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
                    [imageData writeToFile:imageFilePath atomically:YES];
                    
                    self.imageFilePaths = [self.imageFilePaths arrayByAddingObject:imageFilePath];
                }
                
                [self finishLoadItems];
            }];
            
            [provider loadItemForTypeIdentifier:@"com.compuserve.gif" options:nil completionHandler:^(UIImage *image, NSError *error) {
                if (image) {
                    NSString *fileNamePrefix = [NSString stringWithFormat:@"%@", self.startDate];
                    NSString *fileNameSuffix = [NSString stringWithFormat:@"%@", [self.startDate dateByAddingTimeInterval:i + 100]];
//                    NSString *fileNameAndExt = [NSString stringWithFormat:@"%@%@.gif", fileNamePrefix.md5String.md5Middle, fileNameSuffix.md5String.md5Middle];
                    NSString *fileNameAndExt = [NSString stringWithFormat:@"%@%@.jpg", fileNamePrefix, fileNameSuffix];
                    
                    self.imageFilePaths = [self.imageFilePaths arrayByAddingObject:fileNameAndExt];
                }
                
                [self finishLoadItems];
            }];
        }

        if ([provider hasItemConformingToTypeIdentifier:@"public.url"]) {
            [provider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(NSURL *URL, NSError *error) {
                if (URL) {
                    self.URL = URL;
                }
                
                [self finishLoadItems];
            }];
        }
    }
}

- (void)finishLoadItems {
    NSExtensionItem *item = (NSExtensionItem *)self.extensionContext.inputItems.firstObject;
    NSItemProvider *provider = (NSItemProvider *)item.attachments.firstObject;
    if (!self.URL || !self.text || self.imageFilePaths.count + 2 < provider.registeredTypeIdentifiers.count) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf resetTimer];
        [strongSelf stopLoading];
    });
}

#pragma mark - Timer
- (void)startTimer {
    self.countDown = 15;
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerClicked:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)timerClicked:(NSTimer *)sender {
    if (self.countDown < 1) {
        if (!self.loadSuccess) {
            __weak __typeof(self)weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                
                [strongSelf resetTimer];
                [strongSelf stopLoading];
            });
        }
    } else {
        self.countDown -= 1;
        self.waitingLabel.text = [NSString stringWithFormat:@"正在读取，稍等片刻(%02ld)", self.countDown];
    }
}
- (void)stopLoading {
    self.loadSuccess = YES;
    
    [self.indicator stopAnimating];
    self.waitingView.hidden = YES;
    self.contentView.hidden = NO;
    
    self.statusTextView.text = self.text;
    [self.URLButton setTitle:self.URL.absoluteString forState:UIControlStateNormal];
    self.imageNumsLabel.text = [NSString stringWithFormat:@"%ld 条 items\n%ld 条 itemsProvider\n%d 条 public.plain-text\n%d 条 public.url\n%ld 条 public.image", self.extensionContext.inputItems.count, ((NSExtensionItem *)self.extensionContext.inputItems.firstObject).attachments.count, self.text ? 1 : 0, self.URL ? 1 : 0, self.imageFilePaths.count];
}
- (void)resetTimer {
    self.countDown = 15;
    self.waitingLabel.text = [NSString stringWithFormat:@"正在读取，稍等片刻(%02ld)", self.countDown];
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - IBAction
- (IBAction)postButtonDidPress:(UIButton *)sender {
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}
- (IBAction)cancelButtonDidPress:(UIButton *)sender {
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"CustomShareError" code:NSUserCancelledError userInfo:nil]];
}

@end
