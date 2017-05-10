//
//  MNCacheVideoCell.h
//  mipci
//
//  Created by mining on 16/2/29.
//
//

#import <UIKit/UIKit.h>

@interface MNCacheVideoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectImage;

@end
