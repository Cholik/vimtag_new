//
//  MNAccessoryListCell.h
//  mipci
//
//  Created by PC-lizebin on 16/8/12.
//
//

#import <UIKit/UIKit.h>

@interface MNAccessoryListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *accessoryView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UILabel *sceneLabel;


@property (weak, nonatomic) IBOutlet UILabel *awayLabel;
@property (weak, nonatomic) IBOutlet UIImageView *awayFirstImage;
@property (weak, nonatomic) IBOutlet UIImageView *awaySecondImage;
@property (weak, nonatomic) IBOutlet UIImageView *awayThirdImage;
@property (weak, nonatomic) IBOutlet UIImageView *awayFourthImage;

@property (weak, nonatomic) IBOutlet UILabel *activeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activeFirstImage;
@property (weak, nonatomic) IBOutlet UIImageView *activeSecondImage;
@property (weak, nonatomic) IBOutlet UIImageView *activeThirdImage;
@property (weak, nonatomic) IBOutlet UIImageView *activeFourthImage;

@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet UILabel *addLabel;

@property (strong,nonatomic) NSDictionary *dic;

@end
