//
//  RBWeiboShareFetchResultViewController.m
//  ResourceBox
//
//  Created by 龚宇 on 21/02/06.
//

#import "RBWeiboShareFetchResultViewController.h"
#import "RBWeiboShareFetchResultTableViewCell.h"

@interface RBWeiboShareFetchResultViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *listData;

@end

@implementation RBWeiboShareFetchResultViewController

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
    [self.tableView registerNib:[UINib nibWithNibName:@"RBWeiboShareFetchResultTableViewCell" bundle:nil] forCellReuseIdentifier:@"RBWeiboShareFetchResult"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 176;
    self.tableView.tableFooterView = [UIView new];
}
- (void)refresh {
    NSString *rootFolderPath = @"";
    if (self.behavior & RBWeiboShareFetchResultBehaviorSourceWeibo) {
        if (self.behavior & RBWeiboShareFetchResultBehaviorContainerApp) {
            self.title = @"查询已抓取的图片数量(App)";
            rootFolderPath = [RBFileManager shareExtensionWeiboImagesAppContainerFolderPath];
        }
        if (self.behavior & RBWeiboShareFetchResultBehaviorContainerGroup) {
            self.title = @"查询已抓取的图片数量(Group)";
            rootFolderPath = [RBFileManager shareExtensionWeiboImagesGroupContainerFolderPath];
        }
    }
    
    NSArray *folderPaths = [RBFileManager folderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSString *folderName = folderPath.lastPathComponent;
        NSArray *folderComponents = [folderName componentsSeparatedByString:@"+"];
        
        NSString *name = @"[未知用户名]";
        NSString *text = @"[未知内容]";
        NSString *date = @"[未知时间]";
        NSNumber *count = @([RBFileManager filePathsInFolder:folderPath].count);
        
        if (folderComponents.count > 0) {
            name = folderComponents.firstObject;
            date = folderComponents.lastObject;
            if (folderComponents.count > 2) {
                text = [[folderComponents subarrayWithRange:NSMakeRange(1, folderComponents.count - 2)] componentsJoinedByString:@"+"];
            }
        }
        
        [self.listData addObject:NSDictionaryOfVariableBindings(name, text, date, count)];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = self.listData[indexPath.row];
    RBWeiboShareFetchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RBWeiboShareFetchResult"];
    cell.nameLabel.text = [NSString stringWithFormat:@"\t%@", data[@"name"]];
    cell.statusLabel.text = [NSString stringWithFormat:@"\t%@", data[@"text"]];
    cell.timeLabel.text = [NSString stringWithFormat:@"\t%@", [[NSDate dateWithString:data[@"date"] format:RBTimeFormatyMdHmsSCompact] stringWithFormat:RBTimeFormatyMdHmsS]];
    cell.countLabel.text = [NSString stringWithFormat:@"\t%@", data[@"count"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
