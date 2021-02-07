//
//  RBShareImageFetchResultViewController.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/06.
//

#import "RBShareImageFetchResultViewController.h"
#import "RBShareImageFetchResultTableViewCell.h"

#import <MWPhotoBrowser.h>

@interface RBShareImageFetchResultViewController () <UITableViewDelegate, UITableViewDataSource, MWPhotoBrowserDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *listData;
@property (nonatomic, strong) NSMutableArray *photos;

@end

@implementation RBShareImageFetchResultViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUIAndData];
    [self refresh];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // Data
    self.listData = [NSMutableArray array];
    
    // UI
    [self.tableView registerNib:[UINib nibWithNibName:@"RBShareImageFetchResultTableViewCell" bundle:nil] forCellReuseIdentifier:@"RBShareImageFetchResult"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 176;
    self.tableView.tableFooterView = [UIView new];
}
- (void)refresh {
    NSString *rootFolderPath = @"";
    if (self.behavior & RBShareImageFetchResultBehaviorSourceWeibo) {
        if (self.behavior & RBShareImageFetchResultBehaviorContainerApp) {
            self.title = @"查询已抓取的图片数量(App)";
            rootFolderPath = [RBFileManager shareExtensionShareImagesAppContainerFolderPath];
        }
        if (self.behavior & RBShareImageFetchResultBehaviorContainerGroup) {
            self.title = @"查询已抓取的图片数量(Group)";
            rootFolderPath = [RBFileManager shareExtensionShareImagesGroupContainerFolderPath];
        }
    }
    [RBFileManager createFolderAtPath:rootFolderPath];
    
    NSArray *folderPaths = [RBFileManager folderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSString *folderName = folderPath.lastPathComponent;
        NSArray *folderComponents = [folderName componentsSeparatedByString:@"+"];
        
        NSString *name = @"[未知用户名]";
        NSString *text = @"[未知内容]";
        NSString *date = @"[未知时间]";
        NSString *count = [NSString stringWithFormat:@"%ld / %.2fMB", [RBFileManager filePathsInFolder:folderPath].count, [RBFileManager sizeOfFolderAtPath:folderPath] / 1024.0f / 1024.0f];
        
        if (folderComponents.count > 0) {
            name = folderComponents.firstObject;
            date = folderComponents.lastObject;
            if (folderComponents.count > 2) {
                text = [[folderComponents subarrayWithRange:NSMakeRange(1, folderComponents.count - 2)] componentsJoinedByString:@"+"];
            }
        }
        
        [self.listData addObject:NSDictionaryOfVariableBindings(name, text, date, count, folderPath)];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = self.listData[indexPath.row];
    RBShareImageFetchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RBShareImageFetchResult"];
    cell.nameLabel.text = [NSString stringWithFormat:@"\t%@", data[@"name"]];
    cell.statusLabel.text = [NSString stringWithFormat:@"\t%@", data[@"text"]];
    cell.timeLabel.text = [NSString stringWithFormat:@"\t%@", [[NSDate dateWithString:data[@"date"] format:RBTimeFormatyMdHmsSCompact] stringWithFormat:RBTimeFormatyMdHmsS]];
    cell.countLabel.text = [NSString stringWithFormat:@"\t%@", data[@"count"]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.photos = [NSMutableArray array];
    NSString *folderPath = self.listData[indexPath.row][@"folderPath"];
    NSArray *filePaths = [RBFileManager filePathsInFolder:folderPath];
    for (NSInteger i = 0; i < filePaths.count; i++) {
        NSString *filePath = filePaths[i];
        [self.photos addObject:[MWPhoto photoWithURL:[NSURL fileURLWithPath:filePath]]];
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = NO; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    browser.autoPlayOnAppear = NO; // Auto-play first video

    // Present
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count) {
        return self.photos[index];
    }
    
    return nil;
}

@end
