//
//  RBShareImageListViewController.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/06.
//

#import "RBShareImageListViewController.h"

#import "RBShareImageListTableViewCell.h"
#import "RBShareImageFilesViewController.h"
#import "RBShareImageRenameViewController.h"

#import <MJRefresh.h>

@interface RBShareImageListViewController () <UITableViewDelegate, UITableViewDataSource, RBShareImageRenameDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *listData;

@end

@implementation RBShareImageListViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUIAndData];
    
    [self.tableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // Data
    self.listData = [NSMutableArray array];
    
    // UI
    [self.tableView registerNib:[UINib nibWithNibName:@"RBShareImageListTableViewCell" bundle:nil] forCellReuseIdentifier:@"RBShareImageFetchResult"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 176;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
}
- (void)refresh {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        [self _refresh];
    });
}
- (void)_refresh {
    [self.listData removeAllObjects];
    
    NSString *rootFolderPath = @"";
    if (self.behavior & RBShareImageFetchResultBehaviorSourceWeibo) {
        if (self.behavior & RBShareImageFetchResultBehaviorContainerApp) {
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                self.title = @"查询已抓取的图片数量(App)";
            });
            rootFolderPath = [RBFileManager shareExtensionShareImagesAppContainerFolderPath];
        }
        if (self.behavior & RBShareImageFetchResultBehaviorContainerGroup) {
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                self.title = @"查询已抓取的图片数量(Group)";
            });
            rootFolderPath = [RBFileManager shareExtensionShareImagesGroupContainerFolderPath];
        }
    }
    [RBFileManager createFolderAtPath:rootFolderPath];
    
    NSArray *folderPaths = [RBFileManager folderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSString *folderName = folderPath.lastPathComponent;
        
        NSString *name = @"[未知用户名]";
        NSString *text = @"[未知内容]";
        NSString *date = @"[未知时间]";
        NSString *count = [NSString stringWithFormat:@"%ld / %.2fMB", [RBFileManager filePathsInFolder:folderPath].count, [RBFileManager sizeOfFolderAtPath:folderPath] / 1024.0f / 1024.0f];
        
        if ([folderName hasPrefix:RBFileShareExtensionOrderedFolderNamePrefix]) {
            name = folderName;
            date = [[NSDate date] stringWithFormat:RBTimeFormatyMdHmsSCompact];
        } else {
            NSArray *folderComponents = [folderName componentsSeparatedByString:@"+"];
            if (folderComponents.count > 0) {
                name = folderComponents.firstObject;
                date = folderComponents.lastObject;
                if (folderComponents.count > 2) {
                    text = [[folderComponents subarrayWithRange:NSMakeRange(1, folderComponents.count - 2)] componentsJoinedByString:@"+"];
                }
            }
        }
        
        [self.listData addObject:NSDictionaryOfVariableBindings(name, text, date, count, folderPath)];
    }
    
    [self.listData sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]]; // 按时间倒序排列
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    });
}

#pragma mark - Notification
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - RBShareImageRenameDelegate
- (void)didConfirmNewFolderName:(NSString *)newFolderName index:(NSInteger)index {
    NSDictionary *data = self.listData[index];
    NSString *oldFolderPath = data[@"folderPath"];
    NSString *newFolderPath = [oldFolderPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:newFolderName];
    
    NSMutableDictionary *newData = [NSMutableDictionary dictionaryWithDictionary:data];
    newData[@"folderPath"] = newFolderPath;
    NSArray *folderComponents = [newFolderName componentsSeparatedByString:@"+"];
    if (folderComponents.count > 0) {
        newData[@"name"] = folderComponents.firstObject;
        newData[@"date"] = folderComponents.lastObject;
        if (folderComponents.count > 2) {
            newData[@"text"] = [[folderComponents subarrayWithRange:NSMakeRange(1, folderComponents.count - 2)] componentsJoinedByString:@"+"];
        }
    }
    self.listData[index] = [newData copy];
    [self.tableView reloadData];
    
    [RBFileManager moveItemFromPath:oldFolderPath toPath:newFolderPath];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = self.listData[indexPath.row];
    RBShareImageListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RBShareImageFetchResult"];
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
    
    NSString *folderPath = self.listData[indexPath.row][@"folderPath"];
    if ([folderPath.lastPathComponent hasPrefix:RBFileShareExtensionOrderedFolderNamePrefix]) {
        RBShareImageRenameViewController *vc = [[RBShareImageRenameViewController alloc] initWithNibName:@"RBShareImageRenameViewController" bundle:nil];
        vc.index = indexPath.row;
        vc.delegate = self;
        
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        RBShareImageFilesViewController *vc = [[RBShareImageFilesViewController alloc] initWithFolderPath:folderPath andUsername:self.listData[indexPath.row][@"name"]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"是否删除该文件夹？" message:@"此操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
    
    @weakify(self);
    UIAlertAction *cancelAA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    UIAlertAction *confirmAA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        
        NSString *folderPath = self.listData[indexPath.row][@"folderPath"];
        [RBFileManager removeFilePath:folderPath];
        [self.listData removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }];
    
    [ac addAction:cancelAA];
    [ac addAction:confirmAA];
    
    [[RBSettingManager defaultManager].navigationController.visibleViewController presentViewController:ac animated:YES completion:^{}];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

@end
