//
//  RBWeiboShareFetchResultManager.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/06.
//

#import "RBWeiboShareFetchResultManager.h"

@implementation RBWeiboShareFetchResultManager

+ (void)moveImageFilesToAppContainer {
    [RBFileManager createFolderAtPath:[RBFileManager shareExtensionWeiboImagesAppContainerFolderPath]];
    
    NSArray *contentPaths = [RBFileManager contentPathsInFolder:[RBFileManager shareExtensionWeiboImagesGroupContainerFolderPath]];
    for (NSInteger i = 0; i < contentPaths.count; i++) {
        NSString *contentPath = contentPaths[i];
        NSString *destPath = [[RBFileManager shareExtensionWeiboImagesAppContainerFolderPath] stringByAppendingPathComponent:contentPath.lastPathComponent];
        [RBFileManager moveItemFromPath:contentPath toPath:destPath];
        
        [[RBLogManager defaultManager] addDefaultLogWithFormat:@"移动前: %@", contentPath];
        [[RBLogManager defaultManager] addDefaultLogWithFormat:@"移动后: %@", destPath];
    }
    
    [[RBSettingManager defaultManager].viewController.view makeToast:@"已全部完成" duration:1.5 position:CSToastPositionCenter];
}
+ (void)cleanImageFolder {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"是否清理文件夹内所有图片" message:@"此操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    UIAlertAction *confirmAA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [RBWeiboShareFetchResultManager _cleanImageFolder];
    }];
    
    [ac addAction:cancelAA];
    [ac addAction:confirmAA];
    
    [[RBSettingManager defaultManager].navigationController.visibleViewController presentViewController:ac animated:YES completion:^{}];
}
+ (void)_cleanImageFolder {
    [RBFileManager removeFilePath:[RBFileManager shareExtensionWeiboImagesAppContainerFolderPath]];
    
    [[RBSettingManager defaultManager].viewController.view makeToast:@"已全部完成" duration:1.5 position:CSToastPositionCenter];
}

@end
