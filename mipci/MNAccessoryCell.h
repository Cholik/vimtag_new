//
//  MNAccessoryCell.h
//  mipci
//
//  Created by mining on 16/1/12.
//
//

#import <UIKit/UIKit.h>

@interface MNAccessoryCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;

@end
