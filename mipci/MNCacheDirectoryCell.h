//
//  MNCacheDirectoryCell.h
//  mipci
//
//  Created by mining on 16/3/2.
//
//

#import <UIKit/UIKit.h>

@interface MNCacheDirectoryCell : UICollectionViewCell

@property (assign, nonatomic) BOOL      isBox;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@end
