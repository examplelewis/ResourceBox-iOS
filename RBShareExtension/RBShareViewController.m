//
//  RBShareViewController.m
//  RBShareExtension
//
//  Created by 龚宇 on 21/02/04.
//

#import "RBShareViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "RBShareTextModel.h"

static NSInteger const maxTimerCountDown = 30;

@interface RBShareViewController ()

@property (nonatomic, copy) NSArray *imageFilePaths;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) NSInteger loadCount;
@property (nonatomic, assign) BOOL loadSuccess;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger countDown;

@property (strong, nonatomic) IBOutlet UIButton *postButton;

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UITextView *statusTextView;
@property (strong, nonatomic) IBOutlet UIButton *URLButton;
@property (strong, nonatomic) IBOutlet UILabel *imageNumsLabel;

@property (strong, nonatomic) IBOutlet UIView *waitingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UILabel *waitingLabel;

@end

@implementation RBShareViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUIAndData];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        [self readItems];
    });
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.indicator startAnimating];
    [self startTimer];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // UI
    self.contentView.hidden = YES;
    self.waitingView.hidden = NO;
    
    // Data
    self.imageFilePaths = @[];
    self.loadCount = 0;
    self.startDate = [NSDate date];
    
    [RBFileManager createFolderAtPath:[RBFileManager shareExtensionShareImagesGroupContainerFolderPath]];
}

#pragma mark - Read
- (void)readItems {
    NSExtensionItem *item = (NSExtensionItem *)self.extensionContext.inputItems.firstObject;
    for (NSInteger i = 0; i < item.attachments.count; i++) {
        NSItemProvider *provider = (NSItemProvider *)item.attachments[i];
//        NSLog(@"%@", provider.registeredTypeIdentifiers);
        
        @weakify(self);
        if ([provider hasItemConformingToTypeIdentifier:@"public.plain-text"]) {
            [provider loadItemForTypeIdentifier:@"public.plain-text" options:nil completionHandler:^(NSString *text, NSError *error) {
                @strongify(self);
                
                self.text = text;
                [self finishReadItems];
            }];
        }
        if ([provider hasItemConformingToTypeIdentifier:@"public.image"]) {
            // 尽量遵循原图片尺寸、格式
            [provider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(NSData *data, NSError *error) {
                if (data) {
                    @strongify(self);
                    
                    [self processData:data atIndex:i];
                    [self finishReadItems];
                } else if (error.code == -1200) {
                    // -1200 的错误出现意味着，转换成Data失败，需要直接显示成Image
                    [provider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                        if (image) {
                            @strongify(self);
                            
                            [self processData:UIImagePNGRepresentation(image) atIndex:i];
                            [self finishReadItems];
                        }
                    }];
                }
            }];
        }
        if ([provider hasItemConformingToTypeIdentifier:@"public.url"]) {
            [provider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(NSURL *URL, NSError *error) {
                @strongify(self);
                
                self.URL = URL;
                [self finishReadItems];
            }];
        }
    }
}
- (void)processData:(NSData *)data atIndex:(NSInteger)index {
    NSString *fileNamePrefix = [NSString stringWithFormat:@"%@", self.startDate];
    NSString *fileNameSuffix = [NSString stringWithFormat:@"%@", [self.startDate dateByAddingTimeInterval:index + 100]];
    NSString *fileNameAndExt = [NSString stringWithFormat:@"%@%@.%@", fileNamePrefix.md5String.md5Middle, fileNameSuffix.md5String.md5Middle, [self extensionForImageData:data]];
    
    NSString *imageFilePath = [RBFileManager shareExtensionFilePathForShareImageWithName:fileNameAndExt];
//    NSLog(@"imageFilePath: %@", imageFilePath);
    [data writeToFile:imageFilePath atomically:YES];
    
    self.imageFilePaths = [self.imageFilePaths arrayByAddingObject:imageFilePath];
}
- (void)finishReadItems {
    NSExtensionItem *item = (NSExtensionItem *)self.extensionContext.inputItems.firstObject;
    if (!self.URL || !self.text || self.imageFilePaths.count + 2 < item.attachments.count) {
        return;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        
        [self resetTimer];
        [self stopReading];
        [self processInfo];
    });
}
- (void)stopReading {
    self.loadSuccess = YES;
    
    [self.indicator stopAnimating];
    self.waitingView.hidden = YES;
    self.contentView.hidden = NO;
    
    self.statusTextView.text = self.text;
    [self.URLButton setTitle:self.URL.absoluteString forState:UIControlStateNormal];
    self.imageNumsLabel.text = [NSString stringWithFormat:@"%ld 条 items\n%ld 条 itemsProvider\n%d 条 public.plain-text\n%d 条 public.url\n%ld 条 public.image", self.extensionContext.inputItems.count, ((NSExtensionItem *)self.extensionContext.inputItems.firstObject).attachments.count, self.text ? 1 : 0, self.URL ? 1 : 0, self.imageFilePaths.count];
}

#pragma mark - Process
- (void)processInfo {
    NSString *folderName = [self folderNameFromWeiboText];
    NSString *folderPath = [[RBFileManager shareExtensionShareImagesGroupContainerFolderPath] stringByAppendingPathComponent:folderName];
    [RBFileManager createFolderAtPath:folderPath];
    
    for (NSInteger i = 0; i < self.imageFilePaths.count; i++) {
        NSString *originPath = self.imageFilePaths[i];
        NSString *destPath = [folderPath stringByAppendingPathComponent:originPath.lastPathComponent];
        [RBFileManager moveItemFromPath:originPath toPath:destPath];
        
        [[RBLogManager defaultManager] addDefaultLogWithFormat:@"移动前: %@", originPath];
        [[RBLogManager defaultManager] addDefaultLogWithFormat:@"移动后: %@", destPath];
    }
    
    self.imageNumsLabel.text = [NSString stringWithFormat:@"%ld 条 items\n%ld 条 itemsProvider\n%d 条 public.plain-text\n%d 条 public.url\n%ld 条 public.image\n目标文件夹: %@\n共移动%ld条图片至目标文件夹", self.extensionContext.inputItems.count, ((NSExtensionItem *)self.extensionContext.inputItems.firstObject).attachments.count, self.text ? 1 : 0, self.URL ? 1 : 0, self.imageFilePaths.count, folderName, [RBFileManager filePathsInFolder:folderPath].count];
}
- (NSString *)folderNameFromWeiboText {
    RBShareTextModel *model = [[RBShareTextModel alloc] initWithText:self.text];
    
    // 1、先添加用户昵称
    NSString *folderName = [NSString stringWithFormat:@"%@+", model.userName];

    // 2、添加标签以及文字
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#[^#]+#" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *results = [regex matchesInString:model.text options:0 range:NSMakeRange(0, model.text.length)];
    if (error) {
        [[RBLogManager defaultManager] addErrorLogWithFormat:@"正则解析微博文字中的标签出错，原因：%@", error.localizedDescription];
    }
    if (results.count == 0) {
        // 2.1、没有标签的话，截取前100个文字
        if (model.text.length <= 100) {
            folderName = [folderName stringByAppendingFormat:@"[无标签]+%@+", model.text];
        } else {
            folderName = [folderName stringByAppendingFormat:@"[无标签]+%@+", [model.text substringToIndex:100]];
        }
    } else {
        // 2.2.1、有标签的话，先添加所有标签
        for (NSInteger i = 0; i < results.count; i++) {
            NSTextCheckingResult *result = results[i];
            NSString *hashtag = [model.text substringWithRange:result.range];
            hashtag = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];
            folderName = [folderName stringByAppendingFormat:@"%@+", hashtag];
        }

        // 2.2.2、再添加前60个文字
        NSString *noTagText = model.text;
        for (NSInteger i = results.count - 1; i >= 0; i--) {
            NSTextCheckingResult *result = results[i];
            noTagText = [noTagText stringByReplacingCharactersInRange:result.range withString:@""];
        }
        if (noTagText.length <= 60) {
            folderName = [folderName stringByAppendingFormat:@"%@+", noTagText];
        } else {
            folderName = [folderName stringByAppendingFormat:@"%@+", [noTagText substringToIndex:60]];
        }
    }

    // 3、添加微博发布时间
    // 根据微博内容生成文件夹的名称 时没有时间，因此把最后一个加号去掉
    if (model.dateString.isNotEmpty) {
        folderName = [folderName stringByAppendingFormat:@"%@", model.dateString];
    } else {
        folderName = [folderName substringToIndex:folderName.length - 1];
    }

    // 4、防止有 / 出现以及其他特殊字符
    folderName = [folderName stringByReplacingOccurrencesOfString:@"/" withString:@" "];
    folderName = [folderName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

    return folderName;
}

#pragma mark - Tools
- (NSString *)extensionForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];

    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
    }
    
    return @"jpeg";
}

#pragma mark - Timer
- (void)startTimer {
    self.countDown = maxTimerCountDown;
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerClicked:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)timerClicked:(NSTimer *)sender {
    if (self.countDown < 1) {
        if (!self.loadSuccess) {
            [self resetTimer];
            [self stopReading];
            [self processInfo];
        }
    } else {
        self.countDown -= 1;
        self.waitingLabel.text = [NSString stringWithFormat:@"正在读取，稍等片刻(%02ld)", self.countDown];
    }
}
- (void)resetTimer {
    self.countDown = maxTimerCountDown;
    self.waitingLabel.text = [NSString stringWithFormat:@"正在读取，稍等片刻(%02ld)", self.countDown];
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - IBAction
- (IBAction)postButtonDidPress:(UIButton *)sender {
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

@end
