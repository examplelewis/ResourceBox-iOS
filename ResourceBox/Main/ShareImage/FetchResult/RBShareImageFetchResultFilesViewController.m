//
//  RBShareImageFetchResultFilesViewController.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/09.
//

#import "RBShareImageFetchResultFilesViewController.h"

#import <MWPhotoBrowser.h>

@interface RBShareImageFetchResultFilesViewController () <UITableViewDelegate, UITableViewDataSource, MWPhotoBrowserDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIBarButtonItem *browserBarButtonItem;

@property (nonatomic, copy) NSString *folderPath;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *listData;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbnails;

@end

@implementation RBShareImageFetchResultFilesViewController

#pragma mark - Lifecycle
- (instancetype)initWithFolderPath:(NSString *)folderPath andUsername:(nonnull NSString *)username {
    self = [super init];
    if (self) {
        self.folderPath = folderPath;
        self.username = username;
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUIAndData];
    
    [self refresh];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // Navigation
    self.title = self.username;
    self.browserBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"缩略图" style:UIBarButtonItemStylePlain target:self action:@selector(browserBarButtonItemDidPress:)];
    self.navigationItem.rightBarButtonItem = self.browserBarButtonItem;
    
    // Data
    self.listData = [NSMutableArray array];
    self.photos = [NSMutableArray array];
    self.thumbnails = [NSMutableArray array];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        
        NSArray *filePaths = [RBFileManager filePathsInFolder:self.folderPath];
        for (NSInteger i = 0; i < filePaths.count; i++) {
            NSString *filePath = filePaths[i];
            [self.photos addObject:[MWPhoto photoWithURL:[NSURL fileURLWithPath:filePath]]];
            [self.thumbnails addObject:[MWPhoto photoWithURL:[NSURL fileURLWithPath:filePath]]];
        }
    });
    
    // UI
    self.tableView.tableFooterView = [UIView new];
}
- (void)refresh {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        [self _refresh];
    });
}
- (void)_refresh {
    NSArray *folderPaths = [RBFileManager filePathsInFolder:self.folderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *filePath = folderPaths[i];
        NSString *name = filePath.lastPathComponent;
        NSString *size = [NSString stringWithFormat:@"%.2fMB", [[RBFileManager attribute:NSFileSize ofItemAtPath:filePath] longLongValue] / 1024.0f / 1024.0f];
        
        [self.listData addObject:NSDictionaryOfVariableBindings(name, size)];
    }
    
    [self.listData sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]]; // 按时间倒序排列
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.tableView reloadData];
    });
}

#pragma mark - Action
- (void)browserBarButtonItemDidPress:(UIBarButtonItem *)sender {
    [self showMWPhotoBrowserWithPhotoIndex:-1];
}

#pragma mark - Tool
- (void)showMWPhotoBrowserWithPhotoIndex:(NSInteger)index {
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    if (index == -1) {
        browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
        browser.startOnGrid = YES; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
        [browser setCurrentPhotoIndex:0];
    } else {
        browser.enableGrid = NO; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
        browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
        [browser setCurrentPhotoIndex:index];
    }
    browser.autoPlayOnAppear = NO; // Auto-play first video
    
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    NSDictionary *data = self.listData[indexPath.row];
    cell.textLabel.text = data[@"name"];
    cell.detailTextLabel.text = data[@"size"];
    
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
    
    [self showMWPhotoBrowserWithPhotoIndex:indexPath.row];
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
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < self.thumbnails.count) {
        return self.thumbnails[index];
    }
    
    return nil;
}
@end
