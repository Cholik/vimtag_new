//
//  MNBoxViewCell.h
//  mipci
//
//  Created by weken on 15/4/27.
//
//

#import <UIKit/UIKit.h>

@interface MNBoxViewCell : UICollectionViewCell

@property (assign, nonatomic) BOOL online;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *boxID;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;


-(void)loadWebImage;

@end
