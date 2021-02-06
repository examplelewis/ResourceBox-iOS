//
//  RBWeiboShareFetchResultTableViewCell.h
//  ResourceBox
//
//  Created by 龚宇 on 21/02/06.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RBWeiboShareFetchResultTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;

@end

NS_ASSUME_NONNULL_END
