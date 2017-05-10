//
//  MNSnapshotViewCell.h
//  mipci
//
//  Created by weken on 15/5/19.
//
//

#import <UIKit/UIKit.h>

@interface MNSnapshotViewCell : UICollectionViewCell
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *boxID;

@property (assign, nonatomic) long cluster_id;
@property (assign, nonatomic) long seg_id;
@property (assign, nonatomic) long long start_time;
@property (assign, nonatomic) long long end_time;
@property (assign, nonatomic) long flag;

@property (weak, nonatomic) IBOutlet UIImageView *snapshotImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
