//
//  ShareViewController.m
//  RBShareExtension
//
//  Created by 龚宇 on 21/02/03.
//

#import "ShareViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController ()

@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, assign) NSInteger loadCount;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.images = @[];
    self.loadCount = 0;
    
    for (NSInteger i = 0; i < self.extensionContext.inputItems.count; i++) {
        NSExtensionItem *item = self.extensionContext.inputItems[i];
        for (NSInteger j = 0; j < item.attachments.count; j++) {
            NSItemProvider *provider = item.attachments[j];
            NSLog(@"%@", provider.registeredTypeIdentifiers);
            
            
            if ([provider hasItemConformingToTypeIdentifier:@"public.plain-text"]) {
                [provider loadItemForTypeIdentifier:@"public.plain-text" options:nil completionHandler:^(NSString *text, NSError *error) {
                    if (text) {
                        self.text = text;
                    }
                    
                    [self finishLoadItems];
                }];
            }

            if ([provider hasItemConformingToTypeIdentifier:@"public.image"]) {
                [provider loadItemForTypeIdentifier:@"public.image" options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if (image) {
                        self.images = [self.images arrayByAddingObject:image];
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
}

- (void)finishLoadItems {
    
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectCancel {
    [super didSelectCancel];
}
- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
