//
//  MNBoxSegmentViewCell.h
//  mipci
//
//  Created by mining on 15/10/13.
//
//

#import <UIKit/UIKit.h>

@interface MNBoxSegmentViewCell : UICollectionViewCell

@property (copy, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *boxID;
@property (strong, nonatomic) NSString *token;

@property (assign, nonatomic) long cluster_id;
@property (assign, nonatomic) long seg_id;
@property (assign, nonatomic) long long start_time;
@property (assign, nonatomic) long long end_time;
@property (assign, nonatomic) BOOL  isPhoto;
@property (assign, nonatomic) BOOL  isEvent;
@property (assign, nonatomic) int timeDifference;

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *markImageView;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;

@property (weak, nonatomic) IBOutlet UIImageView *firstImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fourthImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fifthImageView;
@property (assign, nonatomic) BOOL isMotion;
@property (assign, nonatomic) BOOL isSnapshot;
@property (assign, nonatomic) BOOL isDoor;
@property (assign, nonatomic) BOOL isSOS;

- (void)loadWebImage;
- (void)showEventImage;
- (void)cancelNetworkRequest;

@end
